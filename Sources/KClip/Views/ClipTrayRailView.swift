import SwiftUI

struct ClipTrayRailView: View {
  let items: [ClipboardItem]
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
  @State private var leadingIndex = 0
  @State private var scrollMetrics = HorizontalScrollMetrics()
  @State private var draggedItemID: UUID?

  var body: some View {
    ScrollViewReader { proxy in
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 14) {
          ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
            card(item, at: index)
          }
        }
        .padding(.horizontal, 6)
        .background(contentMetricsReader)
        .animation(.spring(response: 0.30, dampingFraction: 0.84), value: items.map(\.id))
      }
      .scrollIndicators(.hidden)
      .coordinateSpace(name: "clip-tray-scroll")
      .background(viewportMetricsReader)
      .mask { HorizontalOverflowFadeView(metrics: scrollMetrics) }
      .frame(height: railHeight)
      .onAppear { syncViewport(with: proxy) }
      .onChange(of: items.map(\.id)) { _, _ in syncViewport(with: proxy) }
      .onChange(of: interaction.selection.index) { _, _ in syncViewport(with: proxy) }
      .onPreferenceChange(HorizontalScrollMetricsKey.self) { scrollMetrics = $0 }
    }
  }

  private func card(_ item: ClipboardItem, at index: Int) -> some View {
    Button { selectIndex(index) } label: {
      TrayCardView(item: item, linkPreviews: linkPreviews, isSelected: index == interaction.selection.index)
    }
      .buttonStyle(.plain)
      .id(item.id)
      .opacity(isStaged ? 1 : 0)
      .offset(y: isStaged ? 0 : 10)
      .animation(.easeOut(duration: 0.14), value: isStaged)
      .transition(cardTransition)
      .contextMenu { ClipCardContextMenu(item: item, previewItem: { previewItem(item) }, editItem: { editItem(item) }, pinItem: { pinItem(item) }, toggleTag: { toggleTag(item, $0) }, resetTags: { resetTags(item) }, deleteItem: { deleteItem(item) }) }
      .onDrag { draggedItemID = item.id; return ClipExportService.itemProvider(for: item) }
      .onDrop(of: [ClipCardDragPayload.contentType], delegate: dropDelegate(for: item))
  }

  private func dropDelegate(for item: ClipboardItem) -> ClipCardDropDelegate {
    ClipCardDropDelegate(item: item, items: items, draggedItemID: $draggedItemID, reorder: reorderItem)
  }

  private func syncViewport(with proxy: ScrollViewProxy) {
    guard items.isEmpty == false else { leadingIndex = 0; return }
    leadingIndex = TrayViewportResolver.targetIndex(for: interaction.selection.index, currentLeadingIndex: leadingIndex, itemCount: items.count)
    let animation = interaction.animateSelectionScroll ? Animation.easeOut(duration: 0.18) : nil
    withTransaction(Transaction(animation: animation)) { proxy.scrollTo(items[leadingIndex].id, anchor: .leading) }
  }

  private var cardTransition: AnyTransition {
    .asymmetric(insertion: .opacity.combined(with: .offset(y: 10)), removal: .opacity.combined(with: .scale(scale: 0.90)).combined(with: .offset(y: 12)))
  }

  private var contentMetricsReader: some View {
    GeometryReader { proxy in
      Color.clear.preference(
        key: HorizontalScrollMetricsKey.self,
        value: HorizontalScrollMetrics(
          contentMinX: proxy.frame(in: .named("clip-tray-scroll")).minX,
          contentMaxX: proxy.frame(in: .named("clip-tray-scroll")).maxX
        )
      )
    }
  }

  private var viewportMetricsReader: some View {
    GeometryReader { proxy in
      Color.clear.preference(
        key: HorizontalScrollMetricsKey.self,
        value: HorizontalScrollMetrics(viewportWidth: proxy.size.width)
      )
    }
  }

  private var railHeight: CGFloat { 174 }
}
