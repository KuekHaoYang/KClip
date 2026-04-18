import AppKit

extension TrayPanelController {
  func closePanel() {
    guard panel.isVisible || permissionGuide.panel.isVisible else { return }
    hideTray()
    permissionGuide.hide()
  }

  func closeAndReturnToPrevious() {
    closePanel()
    DebugTrace.write("closeAndReturnToPrevious -> \(previousApplication?.bundleIdentifier ?? "nil")")
    previousApplication?.activate(options: [.activateAllWindows])
  }

  func paste(_ item: ClipboardItem) {
    guard permissionService.requestAccessIfNeeded() else {
      DebugTrace.write("paste blocked waiting for accessibility trust")
      showPermissionGuide(openSettings: true)
      return
    }
    permissionGuide.hide()
    guard pasteService.preparePaste(text: item.text) else { return }
    store.promoteAfterPaste(id: item.id)
    let targetBundleID = previousApplication?.bundleIdentifier
    DebugTrace.write("paste target=\(targetBundleID ?? "nil") text=\(item.text.prefix(24))")
    closeAndReturnToPrevious()
    handoff.sendWhenReady(targetBundleID: targetBundleID, activateTarget: { [weak self] in
      self?.previousApplication?.activate(options: [.activateAllWindows])
    }) { [pasteService] in
      pasteService.sendPreparedPaste()
    }
  }

  func dismissIfNeeded() {
    guard panel.isVisible else { return }
    guard !TrayDismissGate.shouldIgnoreDismiss(lastToggleAt: lastToggleAt) else { return }
    let location = NSEvent.mouseLocation
    let guideFrame = permissionGuide.panel.isVisible ? permissionGuide.panel.frame : nil
    guard !TrayInteractionBounds.contains(location, trayFrame: panel.frame, guideFrame: guideFrame) else {
      return
    }
    lastToggleAt = .now
    permissionGuide.panel.isVisible ? hideTray() : closePanel()
  }

  func handleKey(_ event: NSEvent) -> Bool {
    guard let command = TrayKeyCommand(event: event) else { return false }
    if case .move(_) = command {
      interaction.setSelectionScrollAnimation(isEnabled: event.isARepeat == false)
    }
    let visibleItems = interaction.visibleItems(from: store.items)
    switch interaction.handle(command, items: visibleItems) {
    case .none:
      break
    case .close:
      closeAndReturnToPrevious()
    case .paste(let item):
      paste(item)
    }
    return true
  }

  func hideTray() {
    dismissMonitor.stop()
    panel.orderOut(nil)
  }
}
