import Foundation

enum TrayDismissGate {
  private static let suppressionInterval: TimeInterval = 0.10

  static func shouldIgnoreDismiss(
    lastToggleAt: Date?,
    now: Date = .now
  ) -> Bool {
    guard let lastToggleAt else { return false }
    return now.timeIntervalSince(lastToggleAt) < suppressionInterval
  }
}
