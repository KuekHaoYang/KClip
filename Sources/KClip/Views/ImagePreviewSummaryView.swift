import SwiftUI

struct ImagePreviewSummaryView: View {
  let item: ClipboardItem
  let compact: Bool

  var body: some View {
    Group {
      if compact { mediaBlock }
      else { expandedBody }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .animation(.spring(response: 0.22, dampingFraction: 0.82), value: item.id)
  }

  private var expandedBody: some View {
    VStack(alignment: .leading, spacing: 14) {
      mediaBlock
      footerBlock
    }
  }

  private var footerBlock: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text(item.text)
        .font(.system(size: 16, weight: .bold, design: .rounded))
        .lineLimit(2)
      Text(item.sourceLine ?? "Clipboard image")
        .font(.system(size: 12, weight: .semibold, design: .rounded))
        .foregroundStyle(Color.white.opacity(0.60))
        .lineLimit(1)
    }
  }

  private var mediaBlock: some View {
    ZStack(alignment: .topLeading) {
      LinearGradient(colors: [Color.white.opacity(0.12), Color.white.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing)
      mediaContent
      badge
    }
    .frame(maxWidth: .infinity)
    .frame(height: compact ? 68 : 152)
    .clipShape(previewShape)
    .overlay(previewShape.stroke(Color.white.opacity(0.08), lineWidth: 1))
  }

  private var badge: some View {
    Label("Image", systemImage: "photo")
      .font(.system(size: compact ? 10 : 11, weight: .bold, design: .rounded))
      .padding(.horizontal, compact ? 9 : 11)
      .padding(.vertical, compact ? 6 : 7)
      .background(Capsule().fill(Color.black.opacity(0.18)))
      .padding(compact ? 10 : 12)
  }

  @ViewBuilder
  private var mediaContent: some View {
    if let image = item.previewImage {
      if compact { compactThumbnail(image) }
      else { expandedImage(image) }
    } else {
      Image(systemName: "photo")
        .font(.system(size: compact ? 22 : 34, weight: .semibold))
        .foregroundStyle(Color.white.opacity(0.55))
    }
  }

  private func compactThumbnail(_ image: NSImage) -> some View {
    Image(nsImage: image)
      .resizable()
      .interpolation(.high)
      .scaledToFill()
      .frame(maxWidth: .infinity)
      .frame(height: 36)
      .background(Color.white.opacity(0.04))
      .clipShape(Capsule(style: .continuous))
      .overlay(Capsule(style: .continuous).stroke(Color.white.opacity(0.10), lineWidth: 1))
      .padding(.horizontal, 10)
      .padding(.top, 22)
      .padding(.bottom, 10)
  }

  private func expandedImage(_ image: NSImage) -> some View {
    Image(nsImage: image)
      .resizable()
      .scaledToFit()
      .padding(14)
      .transition(.scale(scale: 0.98).combined(with: .opacity))
  }

  private var previewShape: RoundedRectangle {
    RoundedRectangle(cornerRadius: 22, style: .continuous)
  }
}
