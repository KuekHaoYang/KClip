import Foundation

extension TrayInteractionModel {
  func visibleItems(from items: [ClipboardItem]) -> [ClipboardItem] {
    items.filter(matches)
  }

  func displayedTags(from items: [ClipboardItem]) -> [ClipTag] {
    let used = Set(items.flatMap(\.tags))
    return ClipTag.trayCases.filter { tag in
      tag == .pinned ? items.contains(where: \.isPinned) || selectedTag == tag : used.contains(tag) || selectedTag == tag
    }
  }

  private func matches(_ item: ClipboardItem) -> Bool {
    matchesSearch(item) && matchesTag(item)
  }

  private func matchesSearch(_ item: ClipboardItem) -> Bool {
    let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    return query.isEmpty || item.text.localizedCaseInsensitiveContains(query)
  }

  private func matchesTag(_ item: ClipboardItem) -> Bool {
    guard let selectedTag else { return true }
    return selectedTag == .pinned ? item.isPinned : item.tags.contains(selectedTag)
  }
}
