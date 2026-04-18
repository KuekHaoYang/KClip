import Foundation

struct ClipboardItem: Codable, Identifiable, Equatable {
  let id: UUID
  let text: String
  let capturedAt: Date
  let sourceAppName: String?
  let sourceBundleID: String?
  let suggestedTags: [ClipTag]
  let manualTags: [ClipTag]
  let suppressedTags: [ClipTag]
  let isPinned: Bool

  enum CodingKeys: String, CodingKey {
    case id
    case text
    case capturedAt
    case sourceAppName
    case sourceBundleID
    case tags
    case suggestedTags
    case manualTags
    case suppressedTags
    case isPinned
  }

  init(
    id: UUID = UUID(),
    text: String,
    capturedAt: Date = .now,
    sourceAppName: String? = nil,
    sourceBundleID: String? = nil,
    suggestedTags: [ClipTag]? = nil,
    manualTags: [ClipTag] = [],
    suppressedTags: [ClipTag] = [],
    isPinned: Bool = false
  ) {
    self.id = id
    self.text = text
    self.capturedAt = capturedAt
    self.sourceAppName = sourceAppName
    self.sourceBundleID = sourceBundleID
    self.suggestedTags = Self.normalized(suggestedTags ?? ClipTag.inferredTags(for: text))
    self.manualTags = Self.normalized(manualTags)
    self.suppressedTags = Self.normalized(suppressedTags)
    self.isPinned = isPinned
  }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(UUID.self, forKey: .id)
    text = try container.decode(String.self, forKey: .text)
    capturedAt = try container.decode(Date.self, forKey: .capturedAt)
    sourceAppName = try container.decodeIfPresent(String.self, forKey: .sourceAppName)
    sourceBundleID = try container.decodeIfPresent(String.self, forKey: .sourceBundleID)
    isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
    let legacyTags = try container.decodeIfPresent([ClipTag].self, forKey: .tags)
    suggestedTags = Self.normalized(
      try container.decodeIfPresent([ClipTag].self, forKey: .suggestedTags) ?? legacyTags ?? [.general]
    )
    manualTags = Self.normalized(try container.decodeIfPresent([ClipTag].self, forKey: .manualTags) ?? [])
    suppressedTags = Self.normalized(
      try container.decodeIfPresent([ClipTag].self, forKey: .suppressedTags) ?? []
    )
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(text, forKey: .text)
    try container.encode(capturedAt, forKey: .capturedAt)
    try container.encodeIfPresent(sourceAppName, forKey: .sourceAppName)
    try container.encodeIfPresent(sourceBundleID, forKey: .sourceBundleID)
    try container.encode(suggestedTags, forKey: .suggestedTags)
    try container.encode(manualTags, forKey: .manualTags)
    try container.encode(suppressedTags, forKey: .suppressedTags)
    try container.encode(isPinned, forKey: .isPinned)
  }

  static func normalized(_ tags: [ClipTag]) -> [ClipTag] {
    var seen = Set<ClipTag>()
    return tags.filter { $0.isAssignable && seen.insert($0).inserted }
  }
}
