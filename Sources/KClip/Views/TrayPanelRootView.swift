import SwiftUI

struct TrayPanelRootView: View {
  let panelWidth: CGFloat
  let store: ClipboardStore
  let linkPreviews: LinkPreviewStore
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
    ZStack(alignment: .bottom) {
      trayLayer
      if isPermissionGranted == false {
        TrayPermissionBlockView(onOpenPermissions: onOpenPermissions, onRestart: onRestartPermissions)
      }
      if let item = interaction.previewItem {
        TrayPreviewStageView(item: item, linkPreviews: linkPreviews, onClose: interaction.dismissPreview)
      }
      if let item = editingItem {
        TrayEditorStageView(item: item, text: $draftText, onCancel: endEditing, onSave: saveEdit)
      }
    }
    .padding(.horizontal, 18)
    .padding(.vertical, 12)
    .frame(width: panelWidth, height: panelHeight, alignment: .bottom)
    .background(Color.clear)
    .background(ScrollViewSuppressionView())
    .background(TrayPanelWindowSizerView(size: panelSize, animated: isStaged))
    .onAppear { stageTray() }
    .onChange(of: store.items) { _, _ in syncFromStore() }
    .onChange(of: interaction.searchText) { _, _ in syncSelection() }
    .onChange(of: interaction.selectedTag) { _, _ in syncSelection() }
  }

  private var trayLayer: some View {
    ClipTrayView(
      items: visibleItems,
      tags: displayedTags,
      linkPreviews: linkPreviews,
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
    .frame(height: TrayPanelLayout.trayContentHeight)
    .blur(radius: overlayActive ? 6 : (isPermissionGranted ? 0 : 5))
    .allowsHitTesting(isPermissionGranted && overlayActive == false)
    .animation(.easeOut(duration: 0.18), value: overlayActive)
  }

  var visibleItems: [ClipboardItem] { interaction.visibleItems(from: store.items) }
  var displayedTags: [ClipTag] { interaction.displayedTags(from: store.items) }
  var overlayActive: Bool { editingItem != nil || interaction.previewItem != nil }
  var panelHeight: CGFloat { overlayActive ? TrayPanelLayout.expandedHeight : TrayPanelLayout.preferredSize.height }
  var panelSize: CGSize { CGSize(width: panelWidth, height: panelHeight) }
}
