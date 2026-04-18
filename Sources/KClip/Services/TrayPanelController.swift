import AppKit
import SwiftUI

@MainActor
final class TrayPanelController {
  let store: ClipboardStore
  let pasteService: PasteActionService
  let permissionService: AccessibilityPermissionService
  let interaction = TrayInteractionModel()
  let dismissMonitor = TrayEventMonitor()
  let applicationTracker = LastActiveApplicationTracker()
  let handoff = PasteHandoffCoordinator()
  let permissionGuide = PermissionGuideController()
  let panel = TrayPanel(
    contentRect: .zero,
    styleMask: [.borderless],
    backing: .buffered,
    defer: false
  )
  var previousApplication: NSRunningApplication?
  var lastToggleAt: Date?
  init(
    store: ClipboardStore,
    pasteService: PasteActionService,
    permissionService: AccessibilityPermissionService
  ) {
    self.store = store
    self.pasteService = pasteService
    self.permissionService = permissionService
    configurePanel()
  }
  func toggle() {
    let now = Date()
    guard !TrayDismissGate.shouldIgnoreDismiss(lastToggleAt: lastToggleAt, now: now) else { return }
    lastToggleAt = now
    panel.isVisible ? closeAndReturnToPrevious() : show()
  }

  func show() {
    rememberPreviousApplication()
    interaction.prepareForPresentation(itemCount: store.items.count)
    let finalFrame = TrayPanelLayout.frame(in: activeVisibleFrame)
    let entryFrame = TrayPanelLayout.entryFrame(for: finalFrame)
    let view = hostingView(for: finalFrame.size)
    panel.contentView = view
    view.layoutSubtreeIfNeeded()
    panel.setFrame(entryFrame, display: false)
    panel.displayIfNeeded()
    panel.alphaValue = 0
    dismissMonitor.startMouse { [weak self] in self?.dismissIfNeeded() }
    panel.orderFrontRegardless()
    panel.makeKey()
    panel.makeFirstResponder(panel.contentView)
    NSApp.activate(ignoringOtherApps: true)
    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.16
      panel.animator().setFrame(finalFrame, display: true)
      panel.animator().alphaValue = 1
    }
  }

  func configurePanel() {
    panel.isOpaque = false
    panel.backgroundColor = .clear
    panel.hasShadow = false
    panel.level = .floating
    panel.hidesOnDeactivate = false
    panel.isMovable = false
    panel.isFloatingPanel = true
    panel.isReleasedWhenClosed = false
    panel.isRestorable = false
    panel.becomesKeyOnlyIfNeeded = true
    panel.onKeyDown = { [weak self] event in self?.handleKey(event) ?? false }
    panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle, .transient]
    panel.isExcludedFromWindowsMenu = true
  }

  func hostingView(for size: CGSize) -> TrayHostingView<TrayPanelRootView> {
    let view = TrayPanelRootView(
      panelWidth: size.width,
      store: store,
      interaction: interaction,
      isPermissionGranted: permissionService.hasAccess(),
      onClose: { [weak self] in self?.closeAndReturnToPrevious() },
      onPasteItem: { [weak self] item in self?.paste(item) },
      onRefocus: { [weak self] in self?.focusTray() },
      onOpenPermissions: { [weak self] in self?.showPermissionGuide(openSettings: true) },
      onRestartPermissions: { [weak self] in self?.restartApp() }
    )
    let hostingView = TrayHostingView(rootView: view)
    hostingView.frame = CGRect(origin: .zero, size: size)
    hostingView.focusRingType = .none
    hostingView.onKeyDown = { [weak self] event in self?.handleKey(event) ?? false }
    return hostingView
  }

  func focusTray() {
    panel.makeKey()
    panel.makeFirstResponder(panel.contentView)
  }

  func rememberPreviousApplication() {
    previousApplication = applicationTracker.currentTarget()
    DebugTrace.write(
      "rememberPreviousApplication current=\(NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? "nil")"
      + " previous=\(previousApplication?.bundleIdentifier ?? "nil")"
    )
  }

  var activeVisibleFrame: CGRect {
    let location = NSEvent.mouseLocation
    let screen = NSScreen.screens.first { NSMouseInRect(location, $0.frame, false) }
    return screen?.visibleFrame ?? NSScreen.main?.visibleFrame ?? CGRect(x: 0, y: 0, width: 900, height: 600)
  }
}
