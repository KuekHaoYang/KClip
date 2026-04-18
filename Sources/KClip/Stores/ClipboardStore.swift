import Foundation
import Observation

@Observable
final class ClipboardStore {
  var items: [ClipboardItem] = []
  let fileURL: URL
  let limit: Int
  let persistenceQueue = DispatchQueue(label: "com.kuekhaoyang.kclip.persistence", qos: .utility)

  init(fileURL: URL, limit: Int = 100) {
    self.fileURL = fileURL
    self.limit = limit
  }

  func delete(id: UUID) { mutateItem(id: id) { _ in nil } }
  func toggleTag(id: UUID, tag: ClipTag) { mutateItem(id: id) { $0.togglingTag(tag) } }
  func resetTags(id: UUID) { mutateItem(id: id) { $0.resettingTags() } }
  func promoteAfterPaste(id: UUID) { moveRegularClipToFront(id: id) }
  func moveClip(id: UUID, to targetID: UUID) { reorderClip(id: id, to: targetID) }

  func togglePin(id: UUID) {
    guard let index = items.firstIndex(where: { $0.id == id }) else { return }
    let updated = items.remove(at: index).togglingPin()
    items.insert(updated, at: regularStartIndex)
    persist()
  }

  func update(id: UUID, text: String) {
    let normalizedText = normalized(text)
    guard normalizedText.isEmpty == false else { return }
    mutateItem(id: id) { $0.updating(text: normalizedText) }
  }

  func load() throws {
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
      items = []
      return
    }
    items = try JSONDecoder().decode([ClipboardItem].self, from: Data(contentsOf: fileURL))
  }

  func save() throws {
    let directoryURL = fileURL.deletingLastPathComponent()
    try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    try JSONEncoder().encode(items).write(to: fileURL, options: .atomic)
  }

  private func mutateItem(id: UUID, transform: (ClipboardItem) -> ClipboardItem?) {
    guard let index = items.firstIndex(where: { $0.id == id }) else { return }
    if let updated = transform(items[index]) { items[index] = updated }
    else { items.remove(at: index) }
    persist()
  }

  private func moveRegularClipToFront(id: UUID) {
    guard let index = items.firstIndex(where: { $0.id == id }), items[index].isPinned == false else { return }
    let item = items.remove(at: index)
    items.insert(item, at: regularStartIndex)
    persist()
  }

  private func reorderClip(id: UUID, to targetID: UUID) {
    guard id != targetID, let moving = items.first(where: { $0.id == id }), let target = items.first(where: { $0.id == targetID }) else { return }
    guard moving.isPinned == target.isPinned else { return }
    let pinnedItems = items.filter(\.isPinned)
    let regularItems = items.filter { $0.isPinned == false }
    let reorderedLane = reorderedLaneItems(pinned: moving.isPinned, movingID: id, targetID: targetID)
    items = moving.isPinned ? reorderedLane + regularItems : pinnedItems + reorderedLane
    persist()
  }

  private func reorderedLaneItems(pinned: Bool, movingID: UUID, targetID: UUID) -> [ClipboardItem] {
    var laneItems = items.filter { $0.isPinned == pinned }
    guard let from = laneItems.firstIndex(where: { $0.id == movingID }), let target = laneItems.firstIndex(where: { $0.id == targetID }) else { return laneItems }
    let toOffset = target > from ? target + 1 : target
    let movingItem = laneItems.remove(at: from)
    let destination = max(0, min(from < toOffset ? toOffset - 1 : toOffset, laneItems.count))
    laneItems.insert(movingItem, at: destination)
    return laneItems
  }
}
