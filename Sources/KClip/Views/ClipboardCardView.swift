import AppKit
import SwiftUI

struct ClipboardCardView: View {
    let item: ClipboardItem
    let index: Int
    let isSelected: Bool
    let isCompact: Bool
    let pinboards: [Pinboard]
    let onSelect: () -> Void
    let onPreview: () -> Void
    let onPaste: (_ plainText: Bool) -> Void
    let onCopy: () -> Void
    let onRename: () -> Void
    let onDelete: () -> Void
    let onPin: (_ boardID: UUID?) -> Void
    let onOpenOriginal: () -> Void

    private var cardWidth: CGFloat {
        isCompact ? 240 : 286
    }

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 0) {
                topBand
                bodyContent
            }
            .frame(width: cardWidth, height: isCompact ? 260 : 320)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.white.opacity(0.16))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(isSelected ? Color(hex: "59A6FF") : Color.white.opacity(0.1), lineWidth: isSelected ? 2.5 : 1)
            )
            .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 12)
            .overlay(alignment: .topTrailing) {
                if index < 9 {
                    Text("\(index + 1)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color(hex: "11131A"))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.white.opacity(0.84)))
                        .padding(12)
                }
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Paste") {
                onPaste(false)
            }

            Button("Paste as Plain Text") {
                onPaste(true)
            }

            Button("Copy Back to Clipboard") {
                onCopy()
            }

            Button("Quick Preview") {
                onPreview()
            }

            if case .link = item.payload {
                Button("Open Original") {
                    onOpenOriginal()
                }
            }

            if case .file = item.payload {
                Button("Reveal in Finder") {
                    onOpenOriginal()
                }
            }

            Button("Rename") {
                onRename()
            }

            Menu("Pin to Pinboard") {
                ForEach(pinboards) { board in
                    Button(board.title) {
                        onPin(board.id)
                    }
                }

                if item.boardID != nil {
                    Divider()
                    Button("Remove from Pinboard") {
                        onPin(nil)
                    }
                }
            }

            Divider()

            Button("Delete") {
                onDelete()
            }
        }
        .onTapGesture(count: 2, perform: onPreview)
    }

    private var topBand: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                Label(item.kind.label, systemImage: item.kind.iconName)
                    .font(.system(size: 12, weight: .semibold))

                Spacer(minLength: 12)

                Text(item.capturedAt.kclipRelativeString())
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
            }

            Text(item.title)
                .font(.system(size: isCompact ? 19 : 22, weight: .semibold, design: .rounded))
                .lineLimit(2)
        }
        .foregroundStyle(.white)
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    item.kind.accentColor.opacity(0.95),
                    item.kind.accentColor.opacity(0.72),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var bodyContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            previewArea
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.85))
                    .lineLimit(3)

                HStack(spacing: 10) {
                    Label(item.sourceAppName, systemImage: "app.fill")
                        .lineLimit(1)

                    Spacer()

                    Text(item.detailsText)
                        .lineLimit(1)
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.62))
            }
        }
        .padding(18)
    }

    @ViewBuilder
    private var previewArea: some View {
        switch item.payload {
        case let .text(value):
            Text(value)
                .font(.system(size: isCompact ? 15 : 16, weight: .regular))
                .foregroundStyle(.white)
                .lineLimit(isCompact ? 8 : 10)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        case let .link(value):
            VStack(alignment: .leading, spacing: 10) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.12))
                    .overlay(
                        VStack(alignment: .leading, spacing: 8) {
                            Image(systemName: "safari.fill")
                                .font(.system(size: 22, weight: .medium))
                            Text(URL(string: value)?.host() ?? value)
                                .font(.system(size: 15, weight: .semibold))
                                .lineLimit(2)
                            Text(value)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Color.white.opacity(0.72))
                                .lineLimit(2)
                        }
                        .foregroundStyle(.white)
                        .padding(16)
                    )
            }
        case let .image(snapshot):
            if let image = snapshot.nsImage {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        case let .file(snapshot):
            filePreview(title: snapshot.primaryName, detail: snapshot.paths.count == 1 ? "Local file" : "\(snapshot.paths.count) files")
        case let .color(snapshot):
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(hex: snapshot.hex))
                .overlay(
                    Text(snapshot.hex)
                        .font(.system(size: 15, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.white.opacity(0.92))
                )
        case .pdf:
            filePreview(title: "PDF Preview", detail: item.detailsText, icon: "doc.richtext")
        }
    }

    private func filePreview(title: String, detail: String, icon: String = "doc.fill") -> some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.12))
                .overlay(
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: icon)
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(.white)
                        Text(title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                        Text(detail)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.72))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(16)
                )
        }
    }
}
