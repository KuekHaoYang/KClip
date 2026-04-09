import AppKit
import CryptoKit
import Foundation
import SwiftUI

enum ClipboardKind: String, Codable, CaseIterable, Identifiable {
    case text
    case link
    case image
    case file
    case color
    case pdf

    var id: String { rawValue }

    var label: String {
        switch self {
        case .text:
            "Text"
        case .link:
            "Link"
        case .image:
            "Image"
        case .file:
            "File"
        case .color:
            "Color"
        case .pdf:
            "PDF"
        }
    }

    var iconName: String {
        switch self {
        case .text:
            "text.alignleft"
        case .link:
            "link"
        case .image:
            "photo"
        case .file:
            "doc"
        case .color:
            "eyedropper.halffull"
        case .pdf:
            "doc.richtext"
        }
    }

    var accentColor: Color {
        switch self {
        case .text:
            Color(hex: "FF9F5A")
        case .link:
            Color(hex: "5A9FFF")
        case .image:
            Color(hex: "2EC27E")
        case .file:
            Color(hex: "F5C451")
        case .color:
            Color(hex: "D064FF")
        case .pdf:
            Color(hex: "FF6B6B")
        }
    }
}

struct SizeSnapshot: Codable, Hashable {
    var width: Double
    var height: Double
}

struct ImageSnapshot: Codable, Hashable {
    var pngData: Data
    var size: SizeSnapshot

    var nsImage: NSImage? {
        NSImage(data: pngData)
    }
}

struct FileSnapshot: Codable, Hashable {
    var paths: [String]
    var primaryName: String

    var primaryURL: URL? {
        paths.first.map(URL.init(fileURLWithPath:))
    }
}

struct ColorSnapshot: Codable, Hashable {
    var hex: String
}

struct PDFSnapshot: Codable, Hashable {
    var data: Data
}

enum ClipboardPayload: Hashable, Codable {
    case text(String)
    case link(String)
    case image(ImageSnapshot)
    case file(FileSnapshot)
    case color(ColorSnapshot)
    case pdf(PDFSnapshot)

    private enum CodingKeys: String, CodingKey {
        case type
        case text
        case image
        case file
        case color
        case pdf
    }

    private enum PayloadType: String, Codable {
        case text
        case link
        case image
        case file
        case color
        case pdf
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(PayloadType.self, forKey: .type)

        switch type {
        case .text:
            self = .text(try container.decode(String.self, forKey: .text))
        case .link:
            self = .link(try container.decode(String.self, forKey: .text))
        case .image:
            self = .image(try container.decode(ImageSnapshot.self, forKey: .image))
        case .file:
            self = .file(try container.decode(FileSnapshot.self, forKey: .file))
        case .color:
            self = .color(try container.decode(ColorSnapshot.self, forKey: .color))
        case .pdf:
            self = .pdf(try container.decode(PDFSnapshot.self, forKey: .pdf))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .text(value):
            try container.encode(PayloadType.text, forKey: .type)
            try container.encode(value, forKey: .text)
        case let .link(value):
            try container.encode(PayloadType.link, forKey: .type)
            try container.encode(value, forKey: .text)
        case let .image(value):
            try container.encode(PayloadType.image, forKey: .type)
            try container.encode(value, forKey: .image)
        case let .file(value):
            try container.encode(PayloadType.file, forKey: .type)
            try container.encode(value, forKey: .file)
        case let .color(value):
            try container.encode(PayloadType.color, forKey: .type)
            try container.encode(value, forKey: .color)
        case let .pdf(value):
            try container.encode(PayloadType.pdf, forKey: .type)
            try container.encode(value, forKey: .pdf)
        }
    }
}

struct ClipboardItem: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var kind: ClipboardKind
    var sourceAppName: String
    var sourceBundleID: String?
    var capturedAt: Date
    var fingerprint: String
    var boardID: UUID?
    var payload: ClipboardPayload

    init(
        id: UUID = UUID(),
        title: String,
        kind: ClipboardKind,
        sourceAppName: String,
        sourceBundleID: String?,
        capturedAt: Date = .now,
        fingerprint: String,
        boardID: UUID? = nil,
        payload: ClipboardPayload
    ) {
        self.id = id
        self.title = title
        self.kind = kind
        self.sourceAppName = sourceAppName
        self.sourceBundleID = sourceBundleID
        self.capturedAt = capturedAt
        self.fingerprint = fingerprint
        self.boardID = boardID
        self.payload = payload
    }

    var subtitle: String {
        switch payload {
        case let .text(value):
            String(value.replacingOccurrences(of: "\n", with: " ").prefix(140))
        case let .link(value):
            value
        case let .image(snapshot):
            "\(Int(snapshot.size.width)) × \(Int(snapshot.size.height))"
        case let .file(snapshot):
            snapshot.paths.count == 1 ? snapshot.primaryName : "\(snapshot.paths.count) files"
        case let .color(snapshot):
            snapshot.hex
        case let .pdf(snapshot):
            ByteCountFormatter.string(fromByteCount: Int64(snapshot.data.count), countStyle: .file)
        }
    }

    var detailsText: String {
        switch payload {
        case let .text(value):
            "\(value.count) characters"
        case let .link(value):
            URL(string: value)?.host() ?? value
        case let .image(snapshot):
            "\(Int(snapshot.size.width)) × \(Int(snapshot.size.height))"
        case let .file(snapshot):
            snapshot.paths.count == 1 ? "Local file" : "\(snapshot.paths.count) selected files"
        case let .color(snapshot):
            snapshot.hex
        case let .pdf(snapshot):
            ByteCountFormatter.string(fromByteCount: Int64(snapshot.data.count), countStyle: .file)
        }
    }

    var searchableText: String {
        [
            title,
            subtitle,
            kind.label,
            sourceAppName,
            boardID?.uuidString ?? ""
        ].joined(separator: " ").lowercased()
    }

    var plainTextRepresentation: String {
        switch payload {
        case let .text(value):
            value
        case let .link(value):
            value
        case let .image(snapshot):
            "Image \(Int(snapshot.size.width))x\(Int(snapshot.size.height))"
        case let .file(snapshot):
            snapshot.paths.joined(separator: "\n")
        case let .color(snapshot):
            snapshot.hex
        case .pdf:
            title
        }
    }

    static func makeTitle(kind: ClipboardKind, payload: ClipboardPayload) -> String {
        switch payload {
        case let .text(value):
            let collapsed = value
                .split(whereSeparator: \.isNewline)
                .first
                .map(String.init)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return collapsed.isEmpty ? kind.label : String(collapsed.prefix(44))
        case let .link(value):
            return URL(string: value)?.host() ?? value
        case let .image(snapshot):
            return "Image \(Int(snapshot.size.width))×\(Int(snapshot.size.height))"
        case let .file(snapshot):
            return snapshot.primaryName
        case let .color(snapshot):
            return snapshot.hex
        case .pdf:
            return "PDF Document"
        }
    }
}

struct Pinboard: Identifiable, Codable, Hashable {
    enum Accent: String, Codable, CaseIterable, Identifiable {
        case amber
        case coral
        case lime
        case aqua
        case blue
        case rose

        var id: String { rawValue }

        var color: Color {
            switch self {
            case .amber:
                Color(hex: "F5B544")
            case .coral:
                Color(hex: "FF7A66")
            case .lime:
                Color(hex: "8FD14F")
            case .aqua:
                Color(hex: "34C6BE")
            case .blue:
                Color(hex: "4B8DFF")
            case .rose:
                Color(hex: "FF5B8A")
            }
        }
    }

    var id: UUID
    var title: String
    var accent: Accent
    var isShared: Bool

    init(id: UUID = UUID(), title: String, accent: Accent, isShared: Bool = false) {
        self.id = id
        self.title = title
        self.accent = accent
        self.isShared = isShared
    }
}

struct KClipSettings: Codable, Hashable {
    var isMonitoringPaused = false
    var directPasteEnabled = true
    var compactMode = false
    var retentionDays = 30
    var hideDuringScreenShare = true
    var excludedApps: [String] = [
        "com.apple.keychainaccess",
        "1password",
    ]
}

struct PersistedState: Codable {
    var items: [ClipboardItem]
    var boards: [Pinboard]
    var settings: KClipSettings
}

struct ClipboardCapture {
    var kind: ClipboardKind
    var payload: ClipboardPayload
    var fingerprint: String
    var title: String
    var sourceAppName: String
    var sourceBundleID: String?
}

enum Fingerprint {
    static func make(_ source: String) -> String {
        let digest = SHA256.hash(data: Data(source.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    static func make(_ data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
