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
}
