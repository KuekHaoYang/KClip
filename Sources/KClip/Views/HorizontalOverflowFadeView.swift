import SwiftUI

struct HorizontalOverflowFadeView: View {
  let metrics: HorizontalScrollMetrics

  var body: some View {
    GeometryReader { proxy in
      LinearGradient(stops: stops(for: proxy.size.width), startPoint: .leading, endPoint: .trailing)
    }
    .allowsHitTesting(false)
  }

  private func stops(for width: CGFloat) -> [Gradient.Stop] {
    let safeWidth = max(width, 1)
    let fadeWidth = min(36, safeWidth * 0.18)
    let leadingEdge = metrics.hasLeadingOverflow ? fadeWidth / safeWidth : 0
    let trailingEdge = metrics.hasTrailingOverflow ? 1 - (fadeWidth / safeWidth) : 1
    return [
      .init(color: metrics.hasLeadingOverflow ? .clear : .white, location: 0),
      .init(color: .white, location: leadingEdge),
      .init(color: .white, location: trailingEdge),
      .init(color: metrics.hasTrailingOverflow ? .clear : .white, location: 1)
    ]
  }
}
