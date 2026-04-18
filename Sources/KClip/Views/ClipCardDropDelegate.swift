import SwiftUI

struct ClipCardDropDelegate: DropDelegate {
  let item: ClipboardItem
  let items: [ClipboardItem]
  @Binding var draggedItemID: UUID?
  let reorder: (ClipboardItem, ClipboardItem) -> Void

  func dropEntered(info: DropInfo) {
    guard let draggedItemID, draggedItemID != item.id else { return }
    guard let dragged = items.first(where: { $0.id == draggedItemID }) else { return }
    guard dragged.isPinned == item.isPinned else { return }
    reorder(dragged, item)
  }

  func dropUpdated(info: DropInfo) -> DropProposal? {
    DropProposal(operation: .move)
  }

  func performDrop(info: DropInfo) -> Bool {
    draggedItemID = nil
    return true
  }
}
