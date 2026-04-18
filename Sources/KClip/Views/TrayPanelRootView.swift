import SwiftUI

struct TrayPanelRootView: View {
  let panelWidth: CGFloat
  let store: ClipboardStore
  @ObservedObject var interaction: TrayInteractionModel
  let isPermissionGranted: Bool
  let onClose: () -> Void
  let onPasteItem: (ClipboardItem) -> Void
  let onRefocus: () -> Void
  let onOpenPermissions: () -> Void
  let onRestartPermissions: () -> Void

  @State var isStaged = false
  @State var draftText = ""
  @State var editingItem: ClipboardItem?

  var body: some View {
    ZStack {
      ClipTrayView(
        items: visibleItems,
        tags: displayedTags,
        interaction: interaction,
        isStaged: isStaged,
        selectIndex: activate,
        previewItem: preview,
        editItem: beginEditing,
        pinItem: togglePin,
        toggleTag: toggleTag,
        resetTags: resetTags,
        deleteItem: delete,
        reorderItem: reorder
      )
      .blur(radius: overlayActive ? 6 : (isPermissionGranted ? 0 : 5))
      .allowsHitTesting(isPermissionGranted && overlayActive == false)
      .animation(.easeOut(duration: 0.18), value: overlayActive)

      if isPermissionGranted == false {
        TrayPermissionBlockView(onOpenPermissions: onOpenPermissions, onRestart: onRestartPermissions)
      }
      if let item = interaction.previewItem { TrayPreviewStageView(item: item, onClose: interaction.dismissPreview) }
      if editingItem != nil { TrayEditorStageView(text: $draftText, onCancel: endEditing, onSave: saveEdit) }
    }
    .padding(.horizontal, 18)
    .padding(.vertical, 12)
    .frame(width: panelWidth, height: TrayPanelLayout.preferredSize.height)
    .background(Color.clear)
    .background(ScrollViewSuppressionView())
    .onAppear { stageTray() }
    .onChange(of: store.items) { _, _ in syncFromStore() }
    .onChange(of: interaction.searchText) { _, _ in syncSelection() }
    .onChange(of: interaction.selectedTag) { _, _ in syncSelection() }
  }

  var visibleItems: [ClipboardItem] { interaction.visibleItems(from: store.items) }
  var displayedTags: [ClipTag] { interaction.displayedTags(from: store.items) }
  var overlayActive: Bool { editingItem != nil || interaction.previewItem != nil }
}
