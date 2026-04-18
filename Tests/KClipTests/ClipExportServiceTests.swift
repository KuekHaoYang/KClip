import Foundation
import Testing
@testable import KClip

@Suite("ClipExportServiceTests")
struct ClipExportServiceTests {
  @Test
  func suggestedFileNameUsesReadableFirstLine() {
    let item = ClipboardItem(text: "  Hello / Finder  \nSecond line")

    #expect(ClipExportService.suggestedFileName(for: item) == "Hello Finder.txt")
  }

  @Test
  func temporaryExportFileContainsClipText() throws {
    let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    let item = ClipboardItem(text: "line 1\nline 2")

    let fileURL = try ClipExportService.writeTemporaryFile(for: item, directory: directory)

    #expect(fileURL.pathExtension == "txt")
    #expect(try String(contentsOf: fileURL, encoding: .utf8) == "line 1\nline 2")
  }
}
