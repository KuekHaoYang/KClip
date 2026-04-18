import SwiftUI

struct ColorPreviewSummaryView: View {
  let snippet: ColorSnippet
  let compact: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: compact ? 8 : 10) {
      headerRow
      compact ? AnyView(compactPalette) : AnyView(expandedPalette)
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
      if compact == false {
        Text("Preview")
          .font(.system(size: 10, weight: .bold, design: .rounded))
          .foregroundStyle(Color.white.opacity(0.46))
      }
    }
  }

  private var compactPalette: some View {
    HStack(spacing: 8) { ForEach(snippet.samples.prefix(4)) { swatch($0, height: 54) } }
  }

  private var expandedPalette: some View {
    VStack(alignment: .leading, spacing: 10) {
      swatch(snippet.samples[0], height: 88)
      if snippet.samples.count > 1 {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 10) { ForEach(snippet.samples.dropFirst()) { chip($0) } }
        }
      }
    }
  }

  private func swatch(_ sample: ColorSample, height: CGFloat) -> some View {
    RoundedRectangle(cornerRadius: compact ? 14 : 18, style: .continuous)
      .fill(sample.swiftUIColor)
      .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
      .overlay(alignment: .bottomLeading) {
        Text(sample.displayCode)
          .font(.system(size: compact ? 10 : 11, weight: .bold, design: .monospaced))
          .foregroundStyle(Color.white.opacity(0.94))
          .padding(.horizontal, 10)
          .padding(.vertical, 7)
      }
  }

  private func chip(_ sample: ColorSample) -> some View {
    HStack(spacing: 8) {
      Circle().fill(sample.swiftUIColor).frame(width: 14, height: 14)
      Text(sample.displayCode).lineLimit(1)
    }
    .font(.system(size: 10, weight: .bold, design: .monospaced))
    .padding(.horizontal, 10)
    .padding(.vertical, 7)
    .background(Capsule().fill(Color.white.opacity(0.08)))
    .overlay(Capsule().stroke(Color.white.opacity(0.10), lineWidth: 1))
  }
}
