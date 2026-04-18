import AppKit
import UniformTypeIdentifiers

enum ClipExportService {
  static func itemProvider(for item: ClipboardItem) -> NSItemProvider {
    let provider = item.isImage ? NSItemProvider() : NSItemProvider(object: item.text as NSString)
    provider.suggestedName = suggestedFileName(for: item)
    provider.registerDataRepresentation(
      forTypeIdentifier: ClipCardDragPayload.contentType.identifier,
      visibility: .ownProcess
    ) { completion in
      completion(ClipCardDragPayload.data(for: item), nil)
      return nil
    }
    if let imageData = item.imageData {
      provider.registerDataRepresentation(forTypeIdentifier: UTType.png.identifier, visibility: .all) { completion in
        completion(imageData, nil)
        return nil
      }
    }
    provider.registerFileRepresentation(
      forTypeIdentifier: item.isImage ? UTType.png.identifier : UTType.plainText.identifier,
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
    if item.isImage { return "\(cleanedBaseName(for: item.text).replacingOccurrences(of: "×", with: "x")).png" }
    return "\(cleanedBaseName(for: item.text)).txt"
  }

  static func writeTemporaryFile(for item: ClipboardItem, directory: URL = exportDirectory) throws -> URL {
    let sessionDirectory = directory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
    try FileManager.default.createDirectory(at: sessionDirectory, withIntermediateDirectories: true)
    let fileURL = sessionDirectory.appending(path: suggestedFileName(for: item))
    if let imageData = item.imageData { try imageData.write(to: fileURL, options: .atomic) }
    else { try item.text.write(to: fileURL, atomically: true, encoding: .utf8) }
    return fileURL
  }

  private static func cleanedBaseName(for text: String) -> String {
    let head = text.split(whereSeparator: \.isNewline).first.map(String.init) ?? ""
    let cleaned = head
      .replacingOccurrences(of: #"[\\/:*?"<>|]+"#, with: " ", options: .regularExpression)
      .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
      .trimmingCharacters(in: .whitespacesAndNewlines)
    return String((cleaned.isEmpty ? "KClip Clip" : cleaned).prefix(40)).trimmingCharacters(in: .whitespaces)
  }

  private static var exportDirectory: URL {
    FileManager.default.temporaryDirectory.appending(path: "KClipExports", directoryHint: .isDirectory)
  }
}
