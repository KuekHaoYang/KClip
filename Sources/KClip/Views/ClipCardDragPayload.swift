import Foundation
import UniformTypeIdentifiers

struct ClipCardDragPayload: Codable, Equatable {
  let id: UUID

  static let contentType = UTType(exportedAs: "com.kuekhaoyang.kclip.clip-card")

  static func data(for item: ClipboardItem) -> Data? {
    try? JSONEncoder().encode(Self(id: item.id))
  }
}
