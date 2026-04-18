import SwiftUI

extension TrayPanelRootView {
  func stageTray() {
    syncSelection()
    warmLinkPreviews()
    DispatchQueue.main.async {
      withAnimation(.spring(response: 0.24, dampingFraction: 0.86)) { isStaged = true }
    }
  }

  func syncFromStore() {
    syncSelection()
    warmLinkPreviews()
    interaction.syncPreview(with: store.items)
  }

  func syncSelection() {
    interaction.normalize(itemCount: visibleItems.count)
    warmLinkPreviews()
  }

  func activate(_ index: Int) {
    onRefocus()
    guard let item = interaction.activate(index: index, items: visibleItems) else { return }
    onPasteItem(item)
  }

  func preview(_ item: ClipboardItem) {
    withAnimation(.spring(response: 0.30, dampingFraction: 0.84)) { interaction.presentPreview(item) }
  }

  func beginEditing(_ item: ClipboardItem) {
    guard item.isEditable else { return }
    withAnimation(.spring(response: 0.30, dampingFraction: 0.84)) {
      interaction.dismissPreview()
      draftText = item.plainText ?? ""
      editingItem = item
    }
  }

  func togglePin(_ item: ClipboardItem) {
    withAnimation(.spring(response: 0.30, dampingFraction: 0.84)) { store.togglePin(id: item.id) }
  }

  func reorder(_ item: ClipboardItem, over target: ClipboardItem) {
    withAnimation(.spring(response: 0.28, dampingFraction: 0.84)) {
      store.moveClip(id: item.id, to: target.id)
      interaction.selectItem(id: item.id, in: visibleItems)
    }
  }

  func toggleTag(_ item: ClipboardItem, _ tag: ClipTag) {
    withAnimation(.spring(response: 0.30, dampingFraction: 0.84)) { store.toggleTag(id: item.id, tag: tag) }
  }

  func resetTags(_ item: ClipboardItem) {
    withAnimation(.spring(response: 0.30, dampingFraction: 0.84)) { store.resetTags(id: item.id) }
  }

  func delete(_ item: ClipboardItem) {
    withAnimation(.spring(response: 0.30, dampingFraction: 0.84)) {
      if editingItem?.id == item.id { endEditing() }
      if interaction.previewItem?.id == item.id { interaction.dismissPreview() }
      store.delete(id: item.id)
    }
  }

  func saveEdit() {
    guard let editingItem else { return }
    store.update(id: editingItem.id, text: draftText)
    endEditing()
  }

  func endEditing() {
    withAnimation(.spring(response: 0.30, dampingFraction: 0.84)) {
      draftText = ""
      editingItem = nil
    }
    onRefocus()
  }

  func warmLinkPreviews() {
    linkPreviews.warm(visibleItems)
  }
}
