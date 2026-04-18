import SwiftUI

struct TrayCardView: View {
  let item: ClipboardItem
  let linkPreviews: LinkPreviewStore
  let isSelected: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      headerBlock
      contentBlock
      Spacer(minLength: 0)
    }
    .padding(18)
    .frame(width: 222, height: 168, alignment: .topLeading)
    .background(cardShape.fill(fillStyle))
    .overlay(cardShape.stroke(strokeColor, lineWidth: 1))
    .shadow(color: shadowColor, radius: 8, y: 5)
    .scaleEffect(isSelected ? 1 : 0.988)
    .animation(.spring(response: 0.22, dampingFraction: 0.84), value: isSelected)
  }

  private var headerBlock: some View {
    VStack(alignment: .leading, spacing: 9) {
      headerRow
      sourceRow(sourceLine)
    }
  }

  @ViewBuilder
  private var contentBlock: some View {
    if item.isImage {
      ImagePreviewSummaryView(item: item, compact: true)
        .frame(maxWidth: .infinity, minHeight: 88, maxHeight: 88, alignment: .topLeading)
    } else if let preview = linkPreviews.model(for: item) {
      LinkPreviewSummaryView(preview: preview, compact: true)
        .frame(maxWidth: .infinity, minHeight: 88, maxHeight: 88, alignment: .topLeading)
    } else {
      Text(item.text)
        .font(.system(size: 14, weight: .semibold, design: .rounded))
        .lineSpacing(1.5)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, minHeight: 88, maxHeight: 88, alignment: .topLeading)
        .mask { OverflowFadeView(isEnabled: item.text.count > 110) }
    }
  }

  private var headerRow: some View {
    HStack(alignment: .firstTextBaseline, spacing: 10) {
      Text(item.primaryTag.title)
        .font(.system(size: 10, weight: .bold, design: .rounded))
        .foregroundStyle(item.trayCardTagColor)
      Spacer(minLength: 0)
      if item.isPinned { pinMark }
      Text(item.capturedAt.relativeClipTimestamp())
        .font(.system(size: 10, weight: .bold, design: .rounded))
        .foregroundStyle(Color.white.opacity(0.42))
    }
  }

  private func sourceRow(_ line: String) -> some View {
    HStack(spacing: 7) {
      Circle().fill(Color.white.opacity(0.32)).frame(width: 5, height: 5)
      Text(line).lineLimit(1)
    }
    .font(.system(size: 10, weight: .semibold, design: .rounded))
    .foregroundStyle(Color.white.opacity(0.58))
    .padding(.horizontal, 10)
    .padding(.vertical, 6)
    .background(Capsule().fill(Color.white.opacity(isSelected ? 0.10 : 0.06)))
    .overlay(Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1))
  }

  private var pinMark: some View {
    Image(systemName: "pin.fill")
      .font(.system(size: 9, weight: .bold))
      .foregroundStyle(Color(red: 0.95, green: 0.79, blue: 0.47))
      .padding(.trailing, 1)
  }

  private var sourceLine: String {
    let source = item.sourceAppName ?? item.sourceLine
    let trimmed = source?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    return trimmed.isEmpty ? "Source unavailable" : trimmed
  }

  private var cardShape: RoundedRectangle {
    RoundedRectangle(cornerRadius: 24, style: .continuous)
  }

  private var fillStyle: some ShapeStyle {
    LinearGradient(
      colors: isSelected
        ? [Color.white.opacity(0.16), Color.white.opacity(0.09)]
        : [Color.primary.opacity(0.08), Color.primary.opacity(0.04)],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }

  private var strokeColor: Color {
    isSelected ? .white.opacity(0.28) : .white.opacity(0.10)
  }

  private var shadowColor: Color {
    .black.opacity(isSelected ? 0.14 : 0.07)
  }
}
