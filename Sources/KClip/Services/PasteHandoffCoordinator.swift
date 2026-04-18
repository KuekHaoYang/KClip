import AppKit
import Foundation

struct PasteHandoffCoordinator {
  var frontmostBundleID: () -> String?
  var schedule: (TimeInterval, @escaping () -> Void) -> Void

  init(
    frontmostBundleID: @escaping () -> String? = {
      NSWorkspace.shared.frontmostApplication?.bundleIdentifier
    },
    schedule: @escaping (TimeInterval, @escaping () -> Void) -> Void = { delay, work in
      _ = Timer.scheduledTimer(
        timeInterval: delay,
        target: PasteHandoffTimer(work),
        selector: #selector(PasteHandoffTimer.fire),
        userInfo: nil,
        repeats: false
      )
    }
  ) {
    self.frontmostBundleID = frontmostBundleID
    self.schedule = schedule
  }

  func sendWhenReady(
    targetBundleID: String?,
    attempts: Int = 6,
    interval: TimeInterval = 0.05,
    settleDelay: TimeInterval = 0.04,
    activateTarget: @escaping () -> Void = {},
    send: @escaping () -> Void
  ) {
    DebugTrace.write(
      "handoff attempts=\(attempts) frontmost=\(frontmostBundleID() ?? "nil") target=\(targetBundleID ?? "nil")"
    )
    guard attempts > 0 else {
      DebugTrace.write("handoff fallback send")
      activateTarget()
      schedule(interval, send)
      return
    }
    guard let targetBundleID else {
      DebugTrace.write("handoff send without target")
      send()
      return
    }
    guard frontmostBundleID() != targetBundleID else {
      DebugTrace.write("handoff settled for \(targetBundleID)")
      schedule(settleDelay, send)
      return
    }
    DebugTrace.write("handoff re-activate \(targetBundleID)")
    activateTarget()
    schedule(interval) {
      sendWhenReady(
        targetBundleID: targetBundleID,
        attempts: attempts - 1,
        interval: interval,
        settleDelay: settleDelay,
        activateTarget: activateTarget,
        send: send
      )
    }
  }
}

private final class PasteHandoffTimer: NSObject {
  let work: () -> Void

  init(_ work: @escaping () -> Void) {
    self.work = work
  }

  @objc func fire() {
    work()
  }
}
