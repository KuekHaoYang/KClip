import AppKit
import Foundation

@MainActor
final class ClipboardMonitor {
    private let pasteboard = NSPasteboard.general
    private var timer: Timer?
    private var lastChangeCount = NSPasteboard.general.changeCount

    func start(handler: @escaping @MainActor (ClipboardCapture) -> Void) {
        stop()
        lastChangeCount = pasteboard.changeCount
        timer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.poll(handler: handler)
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func poll(handler: @escaping @MainActor (ClipboardCapture) -> Void) {
        guard pasteboard.changeCount != lastChangeCount else {
            return
        }

        lastChangeCount = pasteboard.changeCount

        guard let capture = makeCapture(from: pasteboard) else {
            return
        }

        Task { @MainActor in
            handler(capture)
        }
    }

    private func makeCapture(from pasteboard: NSPasteboard) -> ClipboardCapture? {
        let sourceApp = NSWorkspace.shared.frontmostApplication
        let sourceName = sourceApp?.localizedName ?? "Unknown App"
        let sourceBundleID = sourceApp?.bundleIdentifier
        let ownBundleID = Bundle.main.bundleIdentifier

        if sourceBundleID == ownBundleID || sourceName == "KClip" {
            return nil
        }

        if let color = NSColor(from: pasteboard) {
            let hex = color.kclipHexString
            let payload = ClipboardPayload.color(ColorSnapshot(hex: hex))
            return ClipboardCapture(
                kind: .color,
                payload: payload,
                fingerprint: Fingerprint.make(hex),
                title: hex,
                sourceAppName: sourceName,
                sourceBundleID: sourceBundleID
            )
        }

        if let urls = pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL], !urls.isEmpty {
            if urls.allSatisfy(\.isFileURL) {
                let snapshot = FileSnapshot(paths: urls.map(\.path), primaryName: urls[0].lastPathComponent)
                let joinedPaths = snapshot.paths.joined(separator: "\n")
                return ClipboardCapture(
                    kind: .file,
                    payload: .file(snapshot),
                    fingerprint: Fingerprint.make(joinedPaths),
                    title: snapshot.primaryName,
                    sourceAppName: sourceName,
                    sourceBundleID: sourceBundleID
                )
            }

            if let url = urls.first {
                let value = url.absoluteString
                return ClipboardCapture(
                    kind: .link,
                    payload: .link(value),
                    fingerprint: Fingerprint.make(value),
                    title: ClipboardItem.makeTitle(kind: .link, payload: .link(value)),
                    sourceAppName: sourceName,
                    sourceBundleID: sourceBundleID
                )
            }
        }

        if let image = NSImage(pasteboard: pasteboard),
           let pngData = image.pngData {
            let snapshot = ImageSnapshot(
                pngData: pngData,
                size: SizeSnapshot(width: image.size.width, height: image.size.height)
            )
            return ClipboardCapture(
                kind: .image,
                payload: .image(snapshot),
                fingerprint: Fingerprint.make(pngData),
                title: ClipboardItem.makeTitle(kind: .image, payload: .image(snapshot)),
                sourceAppName: sourceName,
                sourceBundleID: sourceBundleID
            )
        }

        if let pdfData = pasteboard.data(forType: .pdf) {
            let payload = ClipboardPayload.pdf(PDFSnapshot(data: pdfData))
            return ClipboardCapture(
                kind: .pdf,
                payload: payload,
                fingerprint: Fingerprint.make(pdfData),
                title: "PDF Document",
                sourceAppName: sourceName,
                sourceBundleID: sourceBundleID
            )
        }

        if let string = pasteboard.string(forType: .string), !string.isEmpty {
            let isLikelyURL = URL(string: string)?.scheme != nil
            let kind: ClipboardKind = isLikelyURL ? .link : .text
            let payload: ClipboardPayload = isLikelyURL ? .link(string) : .text(string)
            return ClipboardCapture(
                kind: kind,
                payload: payload,
                fingerprint: Fingerprint.make(string),
                title: ClipboardItem.makeTitle(kind: kind, payload: payload),
                sourceAppName: sourceName,
                sourceBundleID: sourceBundleID
            )
        }

        return nil
    }
}

private extension NSColor {
    var kclipHexString: String {
        guard let rgb = usingColorSpace(.sRGB) else {
            return "#FFFFFF"
        }

        let red = Int(round(rgb.redComponent * 255))
        let green = Int(round(rgb.greenComponent * 255))
        let blue = Int(round(rgb.blueComponent * 255))
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}

private extension NSImage {
    var pngData: Data? {
        guard let tiffData = tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData)
        else {
            return nil
        }

        return bitmap.representation(using: .png, properties: [:])
    }
}
