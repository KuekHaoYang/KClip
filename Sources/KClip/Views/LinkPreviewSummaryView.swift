import SwiftUI

struct LinkPreviewSummaryView: View {
  let preview: LinkPreviewSnapshot
  let compact: Bool

  var body: some View {
    mediaBlock
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }

  private var mediaBlock: some View {
    ZStack(alignment: .topLeading) {
      backgroundBlock
      topShade
      bottomShade
      chromeBar
      statusBadge
      footerBlock
    }
    .clipShape(RoundedRectangle(cornerRadius: compact ? 18 : 20, style: .continuous))
    .overlay(RoundedRectangle(cornerRadius: compact ? 18 : 20, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
  }

  private var footerBlock: some View {
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
    .padding(.horizontal, compact ? 12 : 16)
    .padding(.top, compact ? 18 : 28)
    .padding(.bottom, compact ? 12 : 16)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
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
  private var statusBadge: some View {
    if preview.phase != .ready {
      badgeRow.padding(.horizontal, compact ? 11 : 14).padding(.top, compact ? 11 : 14)
    }
  }

  private var topShade: some View {
    LinearGradient(colors: [.black.opacity(0.10), .clear], startPoint: .top, endPoint: .center)
  }

  private var bottomShade: some View {
    LinearGradient(
      stops: [.init(color: .clear, location: 0.0), .init(color: .black.opacity(compact ? 0.16 : 0.10), location: 0.48), .init(color: .black.opacity(compact ? 0.62 : 0.52), location: 1.0)],
      startPoint: .top,
      endPoint: .bottom
    )
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
        .saturation(0.94)
        .contrast(1.02)
    } else {
      LinearGradient(colors: [Color.white.opacity(0.12), Color.white.opacity(0.03)], startPoint: .topLeading, endPoint: .bottomTrailing)
      VStack(alignment: .leading, spacing: compact ? 6 : 8) {
        Capsule().fill(Color.white.opacity(0.10)).frame(width: compact ? 52 : 72, height: compact ? 6 : 8)
        RoundedRectangle(cornerRadius: compact ? 10 : 12, style: .continuous)
          .fill(Color.white.opacity(0.05))
          .frame(height: compact ? 20 : 32)
        Text(preview.host.uppercased())
          .font(.system(size: compact ? 12 : 17, weight: .black, design: .rounded))
          .foregroundStyle(Color.white.opacity(0.18))
      }
      .padding(compact ? 12 : 16)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
  }
}
