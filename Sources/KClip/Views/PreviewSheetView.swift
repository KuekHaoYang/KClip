import PDFKit
import SwiftUI
import WebKit

struct PreviewSheetView: View {
    @ObservedObject var store: KClipStore
    let itemID: UUID

    @State private var isEditingText = false
    @State private var draftTitle = ""
    @State private var draftBody = ""

    private var item: ClipboardItem? {
        store.items.first(where: { $0.id == itemID })
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
                .overlay(Color.white.opacity(0.08))
            content
        }
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(hex: "151923"))
        )
        .onAppear {
            guard let item else {
                return
            }

            draftTitle = item.title
            draftBody = item.plainTextRepresentation
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(item?.title ?? "Preview")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                if let item {
                    Text("\(item.sourceAppName) · \(item.capturedAt.kclipRelativeString())")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.66))
                }
            }

            Spacer()

            if supportsEditing, !isEditingText {
                Button("Edit") {
                    if let item {
                        draftTitle = item.title
                        draftBody = item.plainTextRepresentation
                    }
                    isEditingText = true
                }
                .buttonStyle(PreviewActionButtonStyle())
            }

            if isEditingText {
                Button("Save") {
                    commitEdits()
                }
                .buttonStyle(PreviewPrimaryActionButtonStyle())
            }

            if isOpenable {
                Button("Open") {
                    store.select(item!)
                    store.openSelected()
                }
                .buttonStyle(PreviewActionButtonStyle())
            }

            Button("Close") {
                store.hidePreview()
            }
            .buttonStyle(PreviewActionButtonStyle())
        }
        .padding(24)
    }

    @ViewBuilder
    private var content: some View {
        if let item {
            switch item.payload {
            case let .text(value):
                textEditor(title: item.title, body: value)
            case let .link(urlString):
                linkPreview(title: item.title, urlString: urlString)
            case let .image(snapshot):
                imagePreview(snapshot: snapshot)
            case let .file(snapshot):
                filePreview(snapshot: snapshot)
            case let .color(snapshot):
                colorPreview(snapshot: snapshot)
            case let .pdf(snapshot):
                pdfPreview(snapshot: snapshot)
            }
        } else {
            EmptyView()
        }
    }

    private var supportsEditing: Bool {
        guard let item else { return false }
        switch item.payload {
        case .text, .link:
            return true
        default:
            return false
        }
    }

    private var isOpenable: Bool {
        guard let item else { return false }
        switch item.payload {
        case .link, .file:
            return true
        default:
            return false
        }
    }

    private func textEditor(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            if isEditingText {
                TextField("Title", text: $draftTitle)
                    .textFieldStyle(.roundedBorder)

                TextEditor(text: $draftBody)
                    .font(.system(size: 15, weight: .regular))
                    .scrollContentBackground(.hidden)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                ScrollView {
                    Text(body)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(.vertical, 8)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func linkPreview(title: String, urlString: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if isEditingText {
                TextField("Title", text: $draftTitle)
                    .textFieldStyle(.roundedBorder)
                TextField("URL", text: $draftBody)
                    .textFieldStyle(.roundedBorder)
            }

            Text(urlString)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.68))

            if let url = URL(string: urlString) {
                WebPreview(url: url)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            } else {
                Text("Invalid URL")
                    .foregroundStyle(.white)
            }
        }
        .padding(24)
    }

    private func imagePreview(snapshot: ImageSnapshot) -> some View {
        ScrollView([.horizontal, .vertical]) {
            if let image = snapshot.nsImage {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .padding(24)
            }
        }
    }

    private func filePreview(snapshot: FileSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                Image(systemName: "doc.fill")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 6) {
                    Text(snapshot.primaryName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("\(snapshot.paths.count) file\(snapshot.paths.count == 1 ? "" : "s")")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.68))
                }
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(snapshot.paths, id: \.self) { path in
                        Text(path)
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.white.opacity(0.08))
                            )
                    }
                }
            }
        }
        .padding(24)
    }

    private func colorPreview(snapshot: ColorSnapshot) -> some View {
        VStack(spacing: 18) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(hex: snapshot.hex))
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Text(snapshot.hex)
                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white)
        }
        .padding(24)
    }

    private func pdfPreview(snapshot: PDFSnapshot) -> some View {
        PDFPreview(data: snapshot.data)
            .padding(24)
    }

    private func commitEdits() {
        guard let item else {
            return
        }

        switch item.payload {
        case .text:
            store.updateTextItem(id: item.id, title: draftTitle, body: draftBody)
        case .link:
            store.updateLinkItem(id: item.id, title: draftTitle, urlString: draftBody)
        default:
            return
        }

        isEditingText = false
    }
}

private struct PreviewActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(configuration.isPressed ? 0.08 : 0.12))
            )
    }
}

private struct PreviewPrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color(hex: "11131A"))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(hex: "F5B24D").opacity(configuration.isPressed ? 0.8 : 1))
            )
    }
}

private struct WebPreview: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.setValue(false, forKey: "drawsBackground")
        view.load(URLRequest(url: url))
        return view
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        guard nsView.url != url else {
            return
        }

        nsView.load(URLRequest(url: url))
    }
}

private struct PDFPreview: NSViewRepresentable {
    let data: Data

    func makeNSView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.document = PDFDocument(data: data)
        return view
    }

    func updateNSView(_ nsView: PDFView, context: Context) {
        nsView.document = PDFDocument(data: data)
    }
}
