import SwiftUI

struct ColorPaletteSurfaceView: View {
  let snippet: ColorSnippet
  let compact: Bool

  var body: some View {
    ZStack {
      Color.clear
      paletteStrip.padding(previewInset)
    }
    .clipShape(outerShape)
    .overlay(innerShape.stroke(Color.white.opacity(0.10), lineWidth: 1).padding(previewInset))
    .overlay(alignment: .bottomLeading) { surfaceGlow.padding(previewInset) }
    .compositingGroup()
    .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.98)), removal: .opacity))
  }

  private var paletteStrip: some View {
    GeometryReader { proxy in
      HStack(spacing: 0) {
        ForEach(snippet.samples) { sample in
          Rectangle().fill(sample.swiftUIColor).frame(width: proxy.size.width / CGFloat(snippet.samples.count))
        }
      }
      .clipShape(innerShape)
    }
  }

  private var surfaceGlow: some View {
    LinearGradient(
      colors: [.clear, .black.opacity(compact ? 0.12 : 0.18)],
      startPoint: .top,
      endPoint: .bottom
    )
    .clipShape(innerShape)
  }

  private var outerCornerRadius: CGFloat { compact ? 22 : 24 }
  private var previewInset: CGFloat { compact ? 8 : 10 }
  private var innerCornerRadius: CGFloat { outerCornerRadius - previewInset }
  private var outerShape: RoundedRectangle { RoundedRectangle(cornerRadius: outerCornerRadius, style: .continuous) }
  private var innerShape: RoundedRectangle { RoundedRectangle(cornerRadius: innerCornerRadius, style: .continuous) }
}
