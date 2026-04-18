import Foundation
import Testing

@Suite("ClipTrayViewportRegressionTests")
struct ClipTrayViewportRegressionTests {
  @Test
  func clipTrayViewUsesLazyCardLoadingForLargeHistory() throws {
    #expect(try railSource().contains("LazyHStack(spacing: 14)"))
  }

  @Test
  func clipTrayViewUsesDedicatedFilterBarInsteadOfToolbarChrome() throws {
    let source = try traySource()
    #expect(source.contains("TrayToolbarView(") == false)
    #expect(source.contains("FooterHintsView") == false)
    #expect(source.contains("TrayFilterBarView("))
  }

  @Test
  func clipTrayViewKeepsEdgeCardsInsetWithoutMaskClipping() throws {
    let source = try railSource()
    let tray = try traySource()
    #expect(source.contains(".padding(.horizontal, 6)"))
    #expect(source.contains(".padding(.vertical, 4)"))
    #expect(source.contains(".mask { HorizontalOverflowFadeView(metrics: scrollMetrics) }"))
    #expect(source.contains("ScrollView(.horizontal, showsIndicators: false)"))
    #expect(source.contains(".scrollIndicators(.hidden)"))
    #expect(source.contains(".frame(height: railHeight)"))
    #expect(tray.contains("VStack(alignment: .leading, spacing: 12)"))
    #expect(source.contains("HiddenHorizontalScrollerView") == false)
  }

  @Test
  func clipTrayViewExposesRichCardContextMenuActions() throws {
    let traySource = try railSource()
    let menuSource = try contextMenuSource()
    #expect(traySource.contains(".contextMenu"))
    #expect(menuSource.contains("Edit Clip"))
    #expect(menuSource.contains("Delete This"))
    #expect(menuSource.contains("Pin This"))
    #expect(menuSource.contains("Manage Tags"))
    #expect(menuSource.contains("Preview"))
  }

  @Test
  func clipTrayUsesViewportResolverForSelectionScrolling() throws {
    let source = try railSource()
    #expect(source.contains("TrayViewportResolver.targetIndex"))
    #expect(source.contains("anchor: .leading"))
    #expect(source.contains("interaction.animateSelectionScroll"))
  }

  @Test
  func clipTrayAnimatesFilterAndCardRemoval() throws {
    #expect(try traySource().contains("TrayFilterBarView("))
    #expect(try railSource().contains("cardTransition"))
    #expect(try railSource().contains("items.map(\\.id)"))
  }

  @Test
  func overflowFadeUsesContentMaskInsteadOfDarkOverlaySlab() throws {
    let source = try fadeSource()
    #expect(source.contains("GeometryReader"))
    #expect(source.contains("LinearGradient(stops:"))
    #expect(source.contains(".white"))
    #expect(source.contains(".clear"))
    #expect(source.contains("Color.black.opacity(0.22)") == false)
    #expect(source.contains("UnevenRoundedRectangle") == false)
  }

  private func traySource() throws -> String {
    try String(contentsOf: sourceURL("Sources/KClip/Views/ClipTrayView.swift"), encoding: .utf8)
  }

  private func railSource() throws -> String {
    try String(contentsOf: sourceURL("Sources/KClip/Views/ClipTrayRailView.swift"), encoding: .utf8)
  }

  private func contextMenuSource() throws -> String {
    try String(contentsOf: sourceURL("Sources/KClip/Views/ClipCardContextMenu.swift"), encoding: .utf8)
  }

  private func fadeSource() throws -> String {
    try String(contentsOf: sourceURL("Sources/KClip/Views/HorizontalOverflowFadeView.swift"), encoding: .utf8)
  }

  private func sourceURL(_ path: String) -> URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appending(path: path)
  }
}
