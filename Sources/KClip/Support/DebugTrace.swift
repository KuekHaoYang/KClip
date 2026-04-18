import Foundation

enum DebugTrace {
  static let isEnabled = ProcessInfo.processInfo.environment["KCLIP_DEBUG_TRACE"] == "1"
  static let logURL = URL(fileURLWithPath: "/tmp/kclip-trace.log")

  static func write(_ message: String) {
    guard isEnabled else { return }
    let line = "\(Date().timeIntervalSince1970): \(message)\n"
    let data = Data(line.utf8)
    if FileManager.default.fileExists(atPath: logURL.path) {
      if let handle = try? FileHandle(forWritingTo: logURL) {
        _ = try? handle.seekToEnd()
        try? handle.write(contentsOf: data)
        try? handle.close()
      }
      return
    }
    try? data.write(to: logURL)
  }
}
