import AppKit
import SwiftUI

@MainActor
final class PermissionGuideController {
  let panel = TrayPanel(contentRect: .zero, styleMask: [.borderless], backing: .buffered, defer: false)
  private var permissionPoll: Timer?
  private var hasPermissionCheck: (() -> Bool)?

  init() {
    panel.isOpaque = false
    panel.backgroundColor = .clear
    panel.hasShadow = false
    panel.level = .floating
    panel.hidesOnDeactivate = false
    panel.isMovable = false
    panel.isMovableByWindowBackground = false
    panel.isFloatingPanel = true
    panel.isReleasedWhenClosed = false
    panel.isRestorable = false
    panel.becomesKeyOnlyIfNeeded = true
    panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
    panel.isExcludedFromWindowsMenu = true
  }

  func show(
    near trayFrame: CGRect,
    on visibleFrame: CGRect,
    bundleURL: URL,
    openSettings: @escaping () -> Void,
    hasPermission: @escaping () -> Bool,
    onRestart: @escaping () -> Void
  ) {
    let frame = PermissionGuideLayout.frame(trayFrame: trayFrame, visibleFrame: visibleFrame)
    let rootView = PermissionGuideRootView(
      bundleURL: bundleURL,
      onOpenSettings: openSettings,
      onRevealInFinder: { NSWorkspace.shared.activateFileViewerSelecting([bundleURL]) },
      onRestart: onRestart
    )
    let hostingView = TrayHostingView(rootView: rootView)
    hostingView.frame = CGRect(origin: .zero, size: frame.size)
    hostingView.focusRingType = .none
    panel.contentView = hostingView
    panel.setFrame(frame, display: false)
    panel.alphaValue = 0
    panel.orderFrontRegardless()
    panel.makeKey()
    panel.makeFirstResponder(hostingView)
    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.18
      panel.animator().alphaValue = 1
    }
    startPolling(hasPermission)
  }

  func hide() {
    guard panel.isVisible else { return }
    permissionPoll?.invalidate()
    permissionPoll = nil
    hasPermissionCheck = nil
    panel.orderOut(nil)
  }

  private func startPolling(_ hasPermission: @escaping () -> Bool) {
    permissionPoll?.invalidate()
    hasPermissionCheck = hasPermission
    permissionPoll = Timer.scheduledTimer(
      timeInterval: 0.5,
      target: self,
      selector: #selector(checkPermission),
      userInfo: nil,
      repeats: true
    )
  }

  @objc private func checkPermission() {
    guard hasPermissionCheck?() == true else { return }
    hide()
  }
}
