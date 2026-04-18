import SwiftUI

struct LinkPreviewSummaryView: View {
  let preview: LinkPreviewSnapshot
  let compact: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: compact ? 8 : 12) {
      HStack(spacing: 8) {
        Image(systemName: "globe")
          .font(.system(size: compact ? 12 : 13, weight: .bold))
        Text(preview.badge)
          .font(.system(size: compact ? 10 : 11, weight: .bold, design: .rounded))
        Spacer(minLength: 0)
        if preview.phase == .loading { ProgressView().controlSize(.small) }
      }
      Text(preview.title)
        .font(.system(size: compact ? 13 : 15, weight: .bold, design: .rounded))
        .lineLimit(compact ? 3 : 2)
      Text(preview.subtitle)
        .font(.system(size: compact ? 10 : 12, weight: .semibold, design: .rounded))
        .foregroundStyle(Color.white.opacity(0.60))
        .lineLimit(1)
      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}
