import SwiftUI

struct ImagePreviewSummaryView: View {
  let item: ClipboardItem
  let compact: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: compact ? 10 : 14) {
      mediaBlock
      VStack(alignment: .leading, spacing: compact ? 3 : 5) {
        Text(item.text)
          .font(.system(size: compact ? 12 : 16, weight: .bold, design: .rounded))
          .lineLimit(compact ? 1 : 2)
        Text(item.sourceLine ?? "Clipboard image")
          .font(.system(size: compact ? 10 : 12, weight: .semibold, design: .rounded))
          .foregroundStyle(Color.white.opacity(0.60))
          .lineLimit(1)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .animation(.spring(response: 0.22, dampingFraction: 0.82), value: item.id)
  }

  private var mediaBlock: some View {
    ZStack(alignment: .topLeading) {
      LinearGradient(colors: [Color.white.opacity(0.12), Color.white.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing)
      if let image = item.previewImage {
        Image(nsImage: image)
          .resizable()
          .scaledToFit()
          .padding(compact ? 10 : 14)
          .transition(.scale(scale: 0.98).combined(with: .opacity))
      } else {
        Image(systemName: "photo")
          .font(.system(size: compact ? 22 : 34, weight: .semibold))
          .foregroundStyle(Color.white.opacity(0.55))
      }
      badge
    }
    .frame(maxWidth: .infinity)
    .frame(height: compact ? 54 : 152)
    .clipShape(RoundedRectangle(cornerRadius: compact ? 16 : 22, style: .continuous))
    .overlay(RoundedRectangle(cornerRadius: compact ? 16 : 22, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
  }

  private var badge: some View {
    Label("Image", systemImage: "photo")
      .font(.system(size: compact ? 10 : 11, weight: .bold, design: .rounded))
      .padding(.horizontal, compact ? 9 : 11)
      .padding(.vertical, compact ? 6 : 7)
      .background(Capsule().fill(Color.black.opacity(0.18)))
      .padding(compact ? 10 : 12)
  }
}
