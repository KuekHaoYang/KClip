import SwiftUI

struct LinkPreviewSummaryView: View {
  let preview: LinkPreviewSnapshot
  let compact: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: compact ? 8 : 12) {
      snapshotBlock
      footerBlock
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }

  private var snapshotHeight: CGFloat { compact ? 54 : 152 }

  private var snapshotBlock: some View {
    ZStack(alignment: .topLeading) {
      snapshotBackground
      chromeBar
      statusBadge
    }
    .frame(maxWidth: .infinity)
    .frame(height: snapshotHeight)
    .background(Color.white.opacity(0.04))
    .clipShape(RoundedRectangle(cornerRadius: compact ? 16 : 20, style: .continuous))
    .overlay(RoundedRectangle(cornerRadius: compact ? 16 : 20, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
  }

  private var footerBlock: some View {
    VStack(alignment: .leading, spacing: compact ? 3 : 5) {
      Text(preview.title)
        .font(.system(size: compact ? 12 : 16, weight: .bold, design: .rounded))
        .foregroundStyle(.white)
        .lineLimit(compact ? 1 : 2)
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
  private var statusBadge: some View {
    if preview.phase != .ready {
      badgeRow.padding(.horizontal, compact ? 11 : 14).padding(.top, compact ? 11 : 14)
    }
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
  private var snapshotBackground: some View {
    if let image = preview.displayImage {
      ZStack {
        Image(nsImage: image)
          .resizable()
          .scaledToFill()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .saturation(0.94)
          .contrast(1.02)
        LinearGradient(colors: [.clear, .black.opacity(compact ? 0.10 : 0.16)], startPoint: .top, endPoint: .bottom)
      }
      .clipped()
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
