import Foundation

enum ClipTag: String, Codable, CaseIterable, Identifiable {
  case pinned
  case general
  case code
  case link
  case note
  case color
  case image

  var id: String { rawValue }
  var isAssignable: Bool { self != .general && self != .pinned }

  var title: String {
    switch self {
    case .pinned: "Pinned"
    case .general: "General"
    case .code: "Code"
    case .link: "Link"
    case .note: "Note"
    case .color: "Color"
    case .image: "Image"
    }
  }

  static var trayCases: [ClipTag] { [.pinned, .code, .link, .note, .color, .image] }
  static var assignableCases: [ClipTag] { trayCases.filter(\.isAssignable) }

  static func inferredTags(for text: String) -> [ClipTag] {
    var tags: [ClipTag] = [.general]
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    let lower = trimmed.lowercased()
    if LinkTextClassifier.url(in: trimmed) != nil { tags.append(.link) }
    if looksLikeCode(lower, text) { tags.append(.code) }
    if trimmed.range(of: "#[0-9a-fA-F]{3,8}", options: .regularExpression) != nil { tags.append(.color) }
    return unique(tags)
  }

  private static func looksLikeCode(_ lower: String, _ text: String) -> Bool {
    let tokens = ["func ", "let ", "var ", "import ", "class ", "struct ", "return "]
    return tokens.contains { lower.contains($0) } || (text.contains("{") && text.contains("}"))
  }

  private static func unique(_ tags: [ClipTag]) -> [ClipTag] {
    var seen = Set<ClipTag>()
    let ordered = tags.filter { seen.insert($0).inserted && $0 != .pinned }
    return ordered.contains(.general) ? ordered : [.general] + ordered
  }
}
