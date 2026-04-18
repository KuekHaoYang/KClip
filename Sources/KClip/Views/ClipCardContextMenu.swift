import SwiftUI

struct ClipCardContextMenu: View {
  let item: ClipboardItem
  let previewItem: () -> Void
  let editItem: () -> Void
  let pinItem: () -> Void
  let toggleTag: (ClipTag) -> Void
  let resetTags: () -> Void
  let deleteItem: () -> Void

  var body: some View {
    Group {
      Button("Preview", action: previewItem)
      if item.isEditable { Button("Edit Clip", action: editItem) }
      Button(item.isPinned ? "Unpin This" : "Pin This", action: pinItem)
      Menu("Manage Tags") {
        ForEach(ClipTag.assignableCases) { tag in
          Button(item.tags.contains(tag) ? "Remove from \(tag.title)" : "Add to \(tag.title)") { toggleTag(tag) }
        }
        Divider()
        Button("Reset Suggested Tags", action: resetTags)
      }
      Divider()
      Button("Delete This", role: .destructive, action: deleteItem)
    }
  }
}
