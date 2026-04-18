import Combine
import Foundation

@MainActor
final class TrayInteractionModel: ObservableObject {
  enum Result: Equatable { case none, close, paste(ClipboardItem) }

  @Published var searchText = ""
  @Published var selectedTag: ClipTag?
  @Published var isSearchPresented = false
  @Published var animateSelectionScroll = true
  @Published var previewItem: ClipboardItem?
  @Published private(set) var selection = MenuBarSelection()

  func prepareForPresentation(itemCount: Int) {
    searchText = ""
    selectedTag = nil
    isSearchPresented = false
    previewItem = nil
    selection = MenuBarSelection()
    selection.normalize(itemCount: itemCount)
  }

  func normalize(itemCount: Int) { selection.normalize(itemCount: itemCount) }
  func selectItem(id: UUID, in items: [ClipboardItem]) {
    guard let index = items.firstIndex(where: { $0.id == id }) else { return }
    selection.index = index
  }

  func visibleItems(from items: [ClipboardItem]) -> [ClipboardItem] {
    items.filter(matches)
  }

  func displayedTags(from items: [ClipboardItem]) -> [ClipTag] {
    let used = Set(items.flatMap(\.tags))
    return ClipTag.trayCases.filter { tag in
      tag == .pinned ? items.contains(where: \.isPinned) || selectedTag == tag : used.contains(tag) || selectedTag == tag
    }
  }

  func activate(index: Int, items: [ClipboardItem]) -> ClipboardItem? {
    guard items.indices.contains(index) else { return nil }
    if selection.index == index { return items[index] }
    selection.index = index
    return nil
  }

  func pasteSelection(items: [ClipboardItem]) -> ClipboardItem? {
    guard items.indices.contains(selection.index) else { return nil }
    return items[selection.index]
  }

  func quickPaste(commandNumber: Int, items: [ClipboardItem]) -> ClipboardItem? {
    guard let index = selection.quickIndex(forCommandNumber: commandNumber, itemCount: items.count) else { return nil }
    selection.index = index
    return items[index]
  }

  func handle(_ command: TrayKeyCommand, items: [ClipboardItem]) -> Result {
    switch command {
    case .move(let delta):
      selection.move(delta: delta, itemCount: items.count)
      if previewItem != nil, items.indices.contains(selection.index) { previewItem = items[selection.index] }
      return .none
    case .pasteSelection: return pasteSelection(items: items).map(Result.paste) ?? .none
    case .quickPaste(let number): return quickPaste(commandNumber: number, items: items).map(Result.paste) ?? .none
    case .togglePreview: togglePreview(items: items); return .none
    case .close:
      if previewItem != nil { previewItem = nil; return .none }
      return .close
    }
  }

  func toggleSearch() { setSearchPresented(isSearchPresented == false) }

  func setSearchPresented(_ isPresented: Bool) {
    if isPresented { selectedTag = nil; isSearchPresented = true; return }
    isSearchPresented = false
    searchText = ""
  }

  func setSelectionScrollAnimation(isEnabled: Bool) { animateSelectionScroll = isEnabled }
  func dismissPreview() { previewItem = nil }

  func syncPreview(with items: [ClipboardItem]) {
    guard let id = previewItem?.id else { return }
    previewItem = items.first { $0.id == id }
  }

  func presentPreview(_ item: ClipboardItem) { previewItem = item }

  func toggleTag(_ tag: ClipTag) {
    setSearchPresented(false)
    selectedTag = selectedTag == tag ? nil : tag
  }

  private func togglePreview(items: [ClipboardItem]) {
    guard items.indices.contains(selection.index) else { previewItem = nil; return }
    let item = items[selection.index]
    previewItem = previewItem?.id == item.id ? nil : item
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
