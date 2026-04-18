import SwiftUI

struct ColorPreviewSummaryView: View {
  let snippet: ColorSnippet
  let compact: Bool

  var body: some View {
    ColorPaletteSurfaceView(snippet: snippet, compact: compact)
      .frame(maxWidth: .infinity, alignment: .topLeading)
      .frame(maxHeight: .infinity, alignment: .topLeading)
      .transition(.asymmetric(insertion: .offset(y: 8).combined(with: .opacity).combined(with: .scale(scale: 0.98)), removal: .opacity))
      .animation(.spring(response: 0.24, dampingFraction: 0.84), value: snippet.samples.map(\.displayCode).joined(separator: ","))
  }
}
