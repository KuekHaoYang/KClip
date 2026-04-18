import SwiftUI

struct ColorPreviewSummaryView: View {
  let snippet: ColorSnippet
  let compact: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: compact ? 8 : 12) {
      headerRow
      paletteSurface
    }
    .padding(compact ? 10 : 14)
    .frame(maxWidth: .infinity, alignment: .topLeading)
    .background(RoundedRectangle(cornerRadius: compact ? 18 : 20, style: .continuous).fill(Color.black.opacity(compact ? 0.16 : 0.20)))
    .overlay(RoundedRectangle(cornerRadius: compact ? 18 : 20, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
    .transition(.asymmetric(insertion: .offset(y: 8).combined(with: .opacity).combined(with: .scale(scale: 0.98)), removal: .opacity))
    .animation(.spring(response: 0.24, dampingFraction: 0.84), value: snippet.samples.map(\.displayCode).joined(separator: ","))
  }

  private var headerRow: some View {
    HStack(spacing: 8) {
      Text(snippet.samples.count == 1 ? "Color" : "\(snippet.samples.count) Colors")
        .font(.system(size: 10, weight: .bold, design: .rounded))
        .foregroundStyle(Color(red: 1.00, green: 0.79, blue: 0.48))
      Spacer(minLength: 0)
      if compact == false {
        Text(codeSummary)
          .lineLimit(1)
          .font(.system(size: 10, weight: .bold, design: .monospaced))
          .foregroundStyle(Color.white.opacity(0.56))
      }
    }
  }

  private var paletteSurface: some View {
    ColorPaletteSurfaceView(snippet: snippet, compact: compact)
      .frame(height: compact ? 58 : 112)
  }

  private var codeSummary: String {
    snippet.samples.map(\.displayCode).joined(separator: "  ")
  }
}
