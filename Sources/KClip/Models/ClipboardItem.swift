import Foundation

struct ClipboardItem: Codable, Identifiable, Equatable {
  let id: UUID
  let text: String
  let plainText: String?
  let imageData: Data?
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
    case plainText
    case imageData
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
    plainText: String? = nil,
    imageData: Data? = nil,
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
    self.plainText = imageData == nil ? (plainText ?? text) : nil
    self.imageData = imageData
    self.capturedAt = capturedAt
    self.sourceAppName = sourceAppName
    self.sourceBundleID = sourceBundleID
    let baseTags = ClipTag.inferredTags(for: self.plainText ?? text, includesImage: imageData != nil)
    self.suggestedTags = Self.normalized((suggestedTags ?? baseTags) + baseTags)
    self.manualTags = Self.normalized(manualTags)
    self.suppressedTags = Self.normalized(suppressedTags)
    self.isPinned = isPinned
  }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(UUID.self, forKey: .id)
    text = try container.decode(String.self, forKey: .text)
    imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
    let storedPlainText = try container.decodeIfPresent(String.self, forKey: .plainText)
    plainText = imageData == nil ? (storedPlainText ?? text) : storedPlainText
    capturedAt = try container.decode(Date.self, forKey: .capturedAt)
    sourceAppName = try container.decodeIfPresent(String.self, forKey: .sourceAppName)
    sourceBundleID = try container.decodeIfPresent(String.self, forKey: .sourceBundleID)
    isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
    let legacyTags = try container.decodeIfPresent([ClipTag].self, forKey: .tags)
    let baseTags = ClipTag.inferredTags(for: plainText ?? text, includesImage: imageData != nil)
    if try container.decodeIfPresent([ClipTag].self, forKey: .suggestedTags) != nil { suggestedTags = baseTags.filter(\.isAssignable) }
    else { suggestedTags = Self.normalized((legacyTags ?? []) + baseTags) }
    manualTags = Self.normalized(try container.decodeIfPresent([ClipTag].self, forKey: .manualTags) ?? [])
    suppressedTags = Self.normalized(
      try container.decodeIfPresent([ClipTag].self, forKey: .suppressedTags) ?? []
    )
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(text, forKey: .text)
    try container.encodeIfPresent(plainText, forKey: .plainText)
    try container.encodeIfPresent(imageData, forKey: .imageData)
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
