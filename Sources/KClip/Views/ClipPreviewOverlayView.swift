import AppKit
import SwiftUI

struct ClipPreviewOverlayView: View {
  let item: ClipboardItem
  let linkPreviews: LinkPreviewStore
  let onClose: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      headerRow
      previewBody.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .padding(20)
    .frame(width: overlaySize.width, height: overlaySize.height, alignment: .topLeading)
    .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(.regularMaterial))
    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.10), lineWidth: 1))
    .onAppear { linkPreviews.warm([item]) }
  }

  private var headerRow: some View {
    HStack(spacing: 10) {
      Text(item.primaryTag.title).font(.system(size: 11, weight: .bold, design: .rounded))
      Spacer(minLength: 0)
      if item.linkURL != nil { actionButton("arrow.up.right.square", openLink) }
      Text(item.capturedAt.relativeClipTimestamp())
        .font(.system(size: 10, weight: .bold, design: .rounded))
        .foregroundStyle(Color.white.opacity(0.48))
      actionButton("xmark.circle.fill", onClose)
    }
  }

  @ViewBuilder
  private var previewBody: some View {
    if item.isImage {
      ImagePreviewSummaryView(item: item, compact: false)
    } else if let preview = linkPreviews.model(for: item) {
      LinkPreviewSummaryView(preview: preview, compact: false)
    } else {
      ScrollView {
        Text(item.text)
          .font(.system(size: 14, weight: .semibold, design: .rounded))
          .textSelection(.enabled)
          .frame(maxWidth: .infinity, alignment: .topLeading)
      }
    }
  }

  private func actionButton(_ symbol: String, _ action: @escaping () -> Void) -> some View {
    Button(action: action) { Image(systemName: symbol).font(.system(size: 14, weight: .semibold)) }
      .buttonStyle(.plain)
  }

  private func openLink() {
    guard let url = item.linkURL else { return }
    NSWorkspace.shared.open(url)
  }

  private var overlaySize: CGSize {
    item.isImage ? CGSize(width: 560, height: 262) : CGSize(width: 500, height: 246)
  }
}
