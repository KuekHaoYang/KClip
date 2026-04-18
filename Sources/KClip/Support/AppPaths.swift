import Foundation

enum AppPaths {
  static var historyFileURL: URL {
    let directory = FileManager.default.urls(
      for: .applicationSupportDirectory,
      in: .userDomainMask
    ).first!

    return directory
      .appendingPathComponent("KClip", isDirectory: true)
      .appendingPathComponent("history.json")
  }

  static var screenshotDirectoryURL: URL {
    let path = (screencaptureDefaults["location"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
    if let path, path.isEmpty == false {
      return URL(fileURLWithPath: NSString(string: path).expandingTildeInPath, isDirectory: true)
    }
    return FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
  }

  static var screenshotNamePrefix: String {
    let name = (screencaptureDefaults["name"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
    return (name?.isEmpty == false ? name : nil) ?? "Screenshot"
  }

  private static var screencaptureDefaults: [String: Any] {
    UserDefaults.standard.persistentDomain(forName: "com.apple.screencapture") ?? [:]
  }
}
