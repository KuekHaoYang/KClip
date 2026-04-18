import SwiftUI

struct ColorPaletteSurfaceView: View {
  let snippet: ColorSnippet
  let compact: Bool

  var body: some View {
    GeometryReader { proxy in
      HStack(spacing: 0) {
        ForEach(snippet.samples) { sample in
          Rectangle()
            .fill(sample.swiftUIColor)
            .frame(width: proxy.size.width / CGFloat(snippet.samples.count))
        }
      }
      .clipShape(shape)
      .overlay(shape.stroke(Color.white.opacity(0.08), lineWidth: 1))
      .overlay(alignment: .bottomLeading) { surfaceGlow }
    }
    .compositingGroup()
    .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.98)), removal: .opacity))
  }

  private var shape: RoundedRectangle {
    RoundedRectangle(cornerRadius: compact ? 16 : 18, style: .continuous)
  }

  private var surfaceGlow: some View {
    LinearGradient(
      colors: [.clear, .black.opacity(compact ? 0.12 : 0.18)],
      startPoint: .top,
      endPoint: .bottom
    )
    .clipShape(shape)
  }
}
