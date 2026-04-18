import Testing
@testable import KClip

@Suite("TrayViewportResolverTests")
struct TrayViewportResolverTests {
  @Test
  func keepsShortHistoriesAnchoredToStart() {
    #expect(TrayViewportResolver.targetIndex(for: 2, currentLeadingIndex: 0, itemCount: 3) == 0)
  }

  @Test
  func shiftsViewportOnlyAfterSelectionLeavesComfortZone() {
    #expect(TrayViewportResolver.targetIndex(for: 2, currentLeadingIndex: 0, itemCount: 8) == 0)
    #expect(TrayViewportResolver.targetIndex(for: 3, currentLeadingIndex: 0, itemCount: 8) == 1)
    #expect(TrayViewportResolver.targetIndex(for: 5, currentLeadingIndex: 2, itemCount: 8) == 3)
  }

  @Test
  func clampsViewportAfterListShrinks() {
    #expect(TrayViewportResolver.targetIndex(for: 4, currentLeadingIndex: 5, itemCount: 6) == 2)
  }
}
