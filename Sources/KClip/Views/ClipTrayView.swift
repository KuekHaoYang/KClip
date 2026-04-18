import SwiftUI

struct ClipTrayView: View {
  let items: [ClipboardItem]
  let tags: [ClipTag]
  let linkPreviews: LinkPreviewStore
  @ObservedObject var interaction: TrayInteractionModel
  let isStaged: Bool
  let selectIndex: (Int) -> Void
  let previewItem: (ClipboardItem) -> Void
  let editItem: (ClipboardItem) -> Void
  let pinItem: (ClipboardItem) -> Void
  let toggleTag: (ClipboardItem, ClipTag) -> Void
  let resetTags: (ClipboardItem) -> Void
  let deleteItem: (ClipboardItem) -> Void
  let reorderItem: (ClipboardItem, ClipboardItem) -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      TrayFilterBarView(tags: tags, interaction: interaction, resultLabel: searchResultsLabel)
      if items.isEmpty { TrayEmptyContentView(title: emptyTitle, subtitle: emptySubtitle) }
      else { cardsRailView }
    }
    .padding(18)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(trayShape.fill(.ultraThinMaterial))
    .overlay { trayShape.stroke(Color.white.opacity(0.10), lineWidth: 1).allowsHitTesting(false) }
    .overlay(alignment: .bottom) {
      LinearGradient(colors: [.clear, Color.white.opacity(0.02), Color.black.opacity(0.12)], startPoint: .top, endPoint: .bottom)
        .clipShape(trayShape)
        .allowsHitTesting(false)
    }
  }

  private var cardsRailView: some View {
    ClipTrayRailView(
      items: items,
      linkPreviews: linkPreviews,
      interaction: interaction,
      isStaged: isStaged,
      selectIndex: selectIndex,
      previewItem: previewItem,
      editItem: editItem,
      pinItem: pinItem,
      toggleTag: toggleTag,
      resetTags: resetTags,
      deleteItem: deleteItem,
      reorderItem: reorderItem
    )
  }

  private var searchResultsLabel: String {
    let count = items.count
    return interaction.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "\(count) clips" : (count == 1 ? "1 result" : "\(count) results")
  }

  private var emptyTitle: String {
    if let tag = interaction.selectedTag { return "No clips in \(tag.title)" }
    return interaction.searchText.isEmpty ? "Clipboard is empty" : "No matching clips"
  }

  private var emptySubtitle: String {
    if interaction.selectedTag == .pinned { return "Pin a clip from the context menu to keep it here." }
    return interaction.searchText.isEmpty ? "Copy something and it will appear here immediately." : "Try another search or switch back to All."
  }

  private var trayShape: RoundedRectangle { RoundedRectangle(cornerRadius: 28, style: .continuous) }
}
