import AppKit

extension TrayPanelController {
  func showPermissionGuide(openSettings: Bool = false) {
    if openSettings { permissionService.openSettings() }
    permissionGuide.show(
      near: panel.frame,
      on: activeVisibleFrame,
      bundleURL: Bundle.main.bundleURL,
      openSettings: permissionService.openSettings,
      hasPermission: permissionService.hasAccess,
      onRestart: { [weak self] in self?.restartApp() }
    )
  }

  func restartApp() {
    let bundleURL = Bundle.main.bundleURL
    let configuration = NSWorkspace.OpenConfiguration()
    closePanel()
    NSWorkspace.shared.openApplication(at: bundleURL, configuration: configuration) { _, _ in
      Task { @MainActor in NSApp.terminate(nil) }
    }
  }
}
