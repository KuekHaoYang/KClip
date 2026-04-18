import SwiftUI

struct OverflowFadeView: View {
  let isEnabled: Bool

  var body: some View {
    if isEnabled {
      LinearGradient(stops: gradientStops, startPoint: .top, endPoint: .bottom)
    } else {
      Rectangle().fill(.black)
    }
  }

  private var gradientStops: [Gradient.Stop] {
    [
      .init(color: .black, location: 0.0),
      .init(color: .black, location: 0.82),
      .init(color: .black.opacity(0.28), location: 0.94),
      .init(color: .clear, location: 1.0),
    ]
  }
}
