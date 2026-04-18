import Foundation
import Testing

@Suite("ClipTrayDragRegressionTests")
struct ClipTrayDragRegressionTests {
  @Test
  func trayUsesDedicatedRailAndDropDelegateForDragReorder() throws {
    let railSource = try source("Sources/KClip/Views/ClipTrayRailView.swift")
    let delegateSource = try source("Sources/KClip/Views/ClipCardDropDelegate.swift")

    #expect(railSource.contains(".onDrag"))
    #expect(railSource.contains(".onDrop"))
    #expect(railSource.contains("ClipCardDropDelegate"))
    #expect(delegateSource.contains("DropProposal(operation: .move)"))
    #expect(delegateSource.contains("draggedItemID"))
  }

  @Test
  func trayDragUsesExportServiceForTextAndFinderDrops() throws {
    let railSource = try source("Sources/KClip/Views/ClipTrayRailView.swift")
    let exportSource = try source("Sources/KClip/Services/ClipExportService.swift")

    #expect(railSource.contains("ClipExportService.itemProvider"))
    #expect(exportSource.contains("registerFileRepresentation"))
    #expect(exportSource.contains("suggestedName"))
    #expect(exportSource.contains("NSString"))
  }

  private func source(_ path: String) throws -> String {
    try String(contentsOf: rootURL.appending(path: path), encoding: .utf8)
  }

  private var rootURL: URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
  }
}
