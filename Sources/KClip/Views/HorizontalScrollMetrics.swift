import CoreGraphics
import SwiftUI

struct HorizontalScrollMetrics: Equatable {
  var contentMinX: CGFloat = 0
  var contentMaxX: CGFloat = 0
  var viewportWidth: CGFloat = 0

  var hasLeadingOverflow: Bool { contentMinX < -8 }
  var hasTrailingOverflow: Bool { contentMaxX > viewportWidth + 8 }
}

struct HorizontalScrollMetricsKey: PreferenceKey {
  static let defaultValue = HorizontalScrollMetrics()

  static func reduce(value: inout HorizontalScrollMetrics, nextValue: () -> HorizontalScrollMetrics) {
    let next = nextValue()
    if next.contentMaxX != 0 || next.contentMinX != 0 {
      value.contentMinX = next.contentMinX
      value.contentMaxX = next.contentMaxX
    }
    value.viewportWidth = max(value.viewportWidth, next.viewportWidth)
  }
}
