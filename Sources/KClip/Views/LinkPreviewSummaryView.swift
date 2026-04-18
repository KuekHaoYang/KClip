import SwiftUI

struct LinkPreviewSummaryView: View {
  let preview: LinkPreviewSnapshot
  let compact: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: compact ? 8 : 12) {
      mediaBlock
        .frame(height: mediaHeight)
      detailsBlock
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }

  private var mediaHeight: CGFloat { compact ? 52 : 136 }

  private var mediaBlock: some View {
    ZStack(alignment: .topLeading) {
      backgroundBlock
      LinearGradient(colors: [.black.opacity(0.02), .black.opacity(compact ? 0.18 : 0.30)], startPoint: .top, endPoint: .bottom)
      chromeBar
      badgeRow.padding(compact ? 11 : 14)
    }
    .clipShape(RoundedRectangle(cornerRadius: compact ? 18 : 20, style: .continuous))
    .overlay(RoundedRectangle(cornerRadius: compact ? 18 : 20, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
  }

  private var detailsBlock: some View {
    VStack(alignment: .leading, spacing: compact ? 4 : 6) {
      Text(preview.title)
        .font(.system(size: compact ? 12 : 16, weight: .bold, design: .rounded))
        .foregroundStyle(.white)
        .lineLimit(compact ? 2 : 3)
      Text(preview.subtitle)
        .font(.system(size: compact ? 10 : 12, weight: .semibold, design: .rounded))
        .foregroundStyle(Color.white.opacity(0.60))
        .lineLimit(1)
    }
  }

  private var badgeRow: some View {
    HStack(spacing: 7) {
      Image(systemName: "globe")
      Text(preview.badge)
      Spacer(minLength: 0)
      if preview.phase == .loading { ProgressView().controlSize(.small) }
    }
    .font(.system(size: compact ? 10 : 11, weight: .bold, design: .rounded))
    .foregroundStyle(.white.opacity(0.92))
  }

  private var chromeBar: some View {
    VStack(spacing: 0) {
      HStack(spacing: 5) {
        ForEach([0.30, 0.24, 0.18], id: \.self) { opacity in
          Circle().fill(Color.white.opacity(opacity)).frame(width: compact ? 5 : 6, height: compact ? 5 : 6)
        }
        Spacer(minLength: 0)
      }
      .padding(.horizontal, compact ? 10 : 12)
      .padding(.top, compact ? 8 : 10)
      Spacer(minLength: 0)
    }
  }

  @ViewBuilder
  private var backgroundBlock: some View {
    if let image = preview.displayImage {
      Image(nsImage: image)
        .resizable()
        .scaledToFill()
        .saturation(0.82)
        .brightness(-0.08)
    } else {
      LinearGradient(colors: [Color.white.opacity(0.12), Color.white.opacity(0.03)], startPoint: .topLeading, endPoint: .bottomTrailing)
      VStack(alignment: .leading, spacing: compact ? 6 : 8) {
        Text(preview.host.uppercased())
          .font(.system(size: compact ? 13 : 18, weight: .black, design: .rounded))
          .foregroundStyle(Color.white.opacity(0.18))
        Capsule().fill(Color.white.opacity(0.08)).frame(width: compact ? 44 : 60, height: compact ? 6 : 8)
      }
      .padding(compact ? 12 : 16)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
  }
}
