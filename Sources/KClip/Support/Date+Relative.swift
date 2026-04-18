import Foundation

extension Date {
  func relativeClipTimestamp(now: Date = .now) -> String {
    let seconds = Int(now.timeIntervalSince(self))
    if seconds < 60 { return "Now" }
    if seconds < 3600 { return "\(seconds / 60)m" }
    if seconds < 86_400 { return "\(seconds / 3600)h" }
    return "\(seconds / 86_400)d"
  }
}
