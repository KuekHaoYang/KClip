import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let store = KClipStore.shared
    private let windowCoordinator = WindowCoordinator.shared
    private var statusController: StatusItemController?
    private var hotKeyCenter: HotKeyCenter?

    func applicationDidFinishLaunching(_ notification: Notification) {
        store.start()
        windowCoordinator.configure(with: store)
        statusController = StatusItemController(store: store, coordinator: windowCoordinator)
        hotKeyCenter = HotKeyCenter(store: store, coordinator: windowCoordinator)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        windowCoordinator.showOverlay()
        return false
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationWillTerminate(_ notification: Notification) {
        store.stop()
    }
}
