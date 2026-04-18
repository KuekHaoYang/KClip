import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
  private var applicationController: TrayApplicationController?

  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.setActivationPolicy(.accessory)
    applicationController = TrayApplicationController()
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    false
  }
}
