import AppKit
import UniformTypeIdentifiers

enum ClipExportService {
  static func itemProvider(for item: ClipboardItem) -> NSItemProvider {
    let provider = NSItemProvider(object: item.text as NSString)
    provider.suggestedName = suggestedFileName(for: item)
    provider.registerDataRepresentation(
      forTypeIdentifier: ClipCardDragPayload.contentType.identifier,
      visibility: .ownProcess
    ) { completion in
      completion(ClipCardDragPayload.data(for: item), nil)
      return nil
    }
    provider.registerFileRepresentation(
      forTypeIdentifier: UTType.plainText.identifier,
      fileOptions: [],
      visibility: .all
    ) { completion in
      do {
        completion(try writeTemporaryFile(for: item), false, nil)
      } catch {
        completion(nil, false, error)
      }
      return nil
    }
    return provider
  }

  static func suggestedFileName(for item: ClipboardItem) -> String {
    let head = item.text.split(whereSeparator: \.isNewline).first.map(String.init) ?? ""
    let cleaned = head
      .replacingOccurrences(of: #"[\\/:*?"<>|]+"#, with: " ", options: .regularExpression)
      .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
      .trimmingCharacters(in: .whitespacesAndNewlines)
    let base = String((cleaned.isEmpty ? "KClip Clip" : cleaned).prefix(40)).trimmingCharacters(in: .whitespaces)
    return "\(base).txt"
  }

  static func writeTemporaryFile(for item: ClipboardItem, directory: URL = exportDirectory) throws -> URL {
    let sessionDirectory = directory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
    try FileManager.default.createDirectory(at: sessionDirectory, withIntermediateDirectories: true)
    let fileURL = sessionDirectory.appending(path: suggestedFileName(for: item))
    try item.text.write(to: fileURL, atomically: true, encoding: .utf8)
    return fileURL
  }

  private static var exportDirectory: URL {
    FileManager.default.temporaryDirectory.appending(path: "KClipExports", directoryHint: .isDirectory)
  }
}
