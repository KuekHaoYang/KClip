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
  private var clickArmedItemID: UUID?

  func prepareForPresentation(itemCount: Int) {
    searchText = ""
    selectedTag = nil
    isSearchPresented = false
    previewItem = nil
    selection = MenuBarSelection()
    normalize(itemCount: itemCount)
  }

  func normalize(itemCount: Int) {
    selection.normalize(itemCount: itemCount)
    disarmClickPaste()
  }

  func selectItem(id: UUID, in items: [ClipboardItem]) {
    guard let index = items.firstIndex(where: { $0.id == id }) else { return }
    selection.index = index
    disarmClickPaste()
  }

  func activate(index: Int, items: [ClipboardItem]) -> ClipboardItem? {
    guard items.indices.contains(index) else { disarmClickPaste(); return nil }
    let item = items[index]
    selection.index = index
    defer { clickArmedItemID = item.id }
    return clickArmedItemID == item.id ? item : nil
  }

  func pasteSelection(items: [ClipboardItem]) -> ClipboardItem? {
    guard items.indices.contains(selection.index) else { return nil }
    return items[selection.index]
  }

  func quickPaste(commandNumber: Int, items: [ClipboardItem]) -> ClipboardItem? {
    guard let index = selection.quickIndex(forCommandNumber: commandNumber, itemCount: items.count) else { return nil }
    selection.index = index
    disarmClickPaste()
    return items[index]
  }

  func handle(_ command: TrayKeyCommand, items: [ClipboardItem]) -> Result {
    switch command {
    case .move(let delta):
      selection.move(delta: delta, itemCount: items.count)
      disarmClickPaste()
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
    disarmClickPaste()
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
    disarmClickPaste()
  }

  private func togglePreview(items: [ClipboardItem]) {
    guard items.indices.contains(selection.index) else { previewItem = nil; return }
    let item = items[selection.index]
    previewItem = previewItem?.id == item.id ? nil : item
  }

  private func disarmClickPaste() { clickArmedItemID = nil }
}
