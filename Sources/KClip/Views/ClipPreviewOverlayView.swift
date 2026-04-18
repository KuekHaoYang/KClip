import SwiftUI

struct ClipPreviewOverlayView: View {
  let item: ClipboardItem
  let onClose: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack(spacing: 10) {
        Text(item.primaryTag.title).font(.system(size: 11, weight: .bold, design: .rounded))
        Spacer(minLength: 0)
        Text(item.capturedAt.relativeClipTimestamp())
          .font(.system(size: 10, weight: .bold, design: .rounded))
          .foregroundStyle(Color.white.opacity(0.48))
        Button(action: onClose) { Image(systemName: "xmark.circle.fill").font(.system(size: 14, weight: .semibold)) }
          .buttonStyle(.plain)
      }
      ScrollView {
        Text(item.text)
          .font(.system(size: 14, weight: .semibold, design: .rounded))
          .textSelection(.enabled)
          .frame(maxWidth: .infinity, alignment: .topLeading)
      }
    }
    .padding(20)
    .frame(width: 470, height: 210, alignment: .topLeading)
    .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(.regularMaterial))
    .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.10), lineWidth: 1))
  }
}
