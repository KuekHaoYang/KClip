import AppKit
import Foundation

@MainActor
final class TrayApplicationController {
  private let model = AppModel()
  private let statusItemController = StatusItemController()
  private lazy var trayPanelController = TrayPanelController(
    store: model.store,
    pasteService: model.pasteService,
    permissionService: model.permissionService
  )

  init() {
    statusItemController.setToggleAction { [weak self] in
      self?.trayPanelController.toggle()
    }
    statusItemController.setQuitAction { NSApp.terminate(nil) }
    if ProcessInfo.processInfo.environment["KCLIP_OPEN_TRAY_ON_LAUNCH"] == "1" {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
        self?.trayPanelController.show()
      }
    }
  }
}
