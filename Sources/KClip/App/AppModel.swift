import Foundation

@MainActor
final class AppModel {
  let store: ClipboardStore
  let linkPreviews: LinkPreviewStore
  let monitor: ClipboardMonitor
  let pasteService: PasteActionService
  let permissionService: AccessibilityPermissionService

  init() {
    let store = ClipboardStore(fileURL: AppPaths.historyFileURL)
    self.store = store
    self.linkPreviews = LinkPreviewStore()
    self.monitor = ClipboardMonitor(store: store)
    self.pasteService = PasteActionService()
    self.permissionService = AccessibilityPermissionService()
    try? store.load()
    monitor.start()
  }
}
