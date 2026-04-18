import AppKit
import Foundation

@MainActor
final class LastActiveApplicationTracker {
  private let appBundleID: String?
  private let center = NSWorkspace.shared.notificationCenter
  private var observer: NSObjectProtocol?
  private var lastBundleID: String?

  init(appBundleID: String? = Bundle.main.bundleIdentifier) {
    self.appBundleID = appBundleID
    capture(NSWorkspace.shared.frontmostApplication)
    observer = center.addObserver(
      forName: NSWorkspace.didActivateApplicationNotification,
      object: nil,
      queue: .main
    ) { [weak self] note in
      let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
      Task { @MainActor [weak self] in
        self?.capture(app)
      }
    }
  }

  func currentTarget() -> NSRunningApplication? {
    if let frontmost = NSWorkspace.shared.frontmostApplication, isExternal(frontmost) {
      return frontmost
    }
    guard let lastBundleID else { return nil }
    return NSWorkspace.shared.runningApplications.first { $0.bundleIdentifier == lastBundleID }
  }

  private func capture(_ app: NSRunningApplication?) {
    guard let app, isExternal(app) else { return }
    lastBundleID = app.bundleIdentifier
  }

  private func isExternal(_ app: NSRunningApplication) -> Bool {
    guard let bundleIdentifier = app.bundleIdentifier else { return false }
    return bundleIdentifier != appBundleID
  }
}
