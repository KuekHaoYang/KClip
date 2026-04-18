import Foundation

enum TrayViewportResolver {
  private static let visibleCardCount = 4

  static func targetIndex(for selection: Int, currentLeadingIndex: Int, itemCount: Int) -> Int {
    guard itemCount > visibleCardCount else { return 0 }
    let maxLeadingIndex = max(0, itemCount - visibleCardCount)
    let leadingIndex = min(currentLeadingIndex, maxLeadingIndex)
    let lowerBound = leadingIndex + 1
    let upperBound = leadingIndex + (visibleCardCount - 2)
    if selection < lowerBound { return max(0, selection - 1) }
    if selection > upperBound { return min(maxLeadingIndex, selection - (visibleCardCount - 2)) }
    return leadingIndex
  }
}
