import AppKit

@MainActor
final class TrayEventMonitor {
  private var localMouseMonitor: Any?
  private var globalMouseMonitor: Any?

  func startMouse(handler: @escaping () -> Void) {
    stopMouse()
    let mask: NSEvent.EventTypeMask = [.leftMouseDown, .rightMouseDown, .otherMouseDown]
    localMouseMonitor = NSEvent.addLocalMonitorForEvents(matching: mask) { event in
      handler()
      return event
    }
    globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: mask) { _ in
      handler()
    }
  }

  func stop() {
    stopMouse()
  }

  private func stopMouse() {
    if let localMouseMonitor { NSEvent.removeMonitor(localMouseMonitor) }
    if let globalMouseMonitor { NSEvent.removeMonitor(globalMouseMonitor) }
    localMouseMonitor = nil
    globalMouseMonitor = nil
  }
}
