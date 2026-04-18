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
      LinearGradient(colors: [.clear, .black.opacity(compact ? 0.12 : 0.22)], startPoint: .top, endPoint: .bottom)
      badgeRow.padding(compact ? 10 : 12)
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

  @ViewBuilder
  private var backgroundBlock: some View {
    if let image = preview.image {
      Image(nsImage: image)
        .resizable()
        .scaledToFill()
        .saturation(0.88)
        .brightness(-0.04)
    } else {
      LinearGradient(colors: [Color.white.opacity(0.12), Color.white.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing)
      Text(preview.host.uppercased())
        .font(.system(size: compact ? 15 : 20, weight: .black, design: .rounded))
        .foregroundStyle(Color.white.opacity(0.14))
        .padding(compact ? 10 : 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
  }
}
