import AppKit
import ApplicationServices
import Foundation

struct AccessibilityPermissionService {
  var isTrusted: () -> Bool
  var canPostEvents: () -> Bool
  var requestAccess: () -> Void
  var openSettings: () -> Void

  init(
    isTrusted: @escaping () -> Bool = { AXIsProcessTrusted() },
    canPostEvents: @escaping () -> Bool = {
      if #available(macOS 10.15, *) { return CGPreflightPostEventAccess() }
      return true
    },
    requestAccess: @escaping () -> Void = {
      _ = AXIsProcessTrustedWithOptions(["AXTrustedCheckOptionPrompt": true] as CFDictionary)
      if #available(macOS 10.15, *) { _ = CGRequestPostEventAccess() }
    },
    openSettings: @escaping () -> Void = {
      guard let url = URL(
        string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
      ) else { return }
      NSWorkspace.shared.open(url)
    }
  ) {
    self.isTrusted = isTrusted
    self.canPostEvents = canPostEvents
    self.requestAccess = requestAccess
    self.openSettings = openSettings
  }

  func hasAccess() -> Bool {
    isTrusted() && canPostEvents()
  }

  func requestAccessIfNeeded() -> Bool {
    guard hasAccess() else {
      requestAccess()
      return false
    }
    return true
  }
}
