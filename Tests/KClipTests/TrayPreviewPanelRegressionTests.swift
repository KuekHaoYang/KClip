import Foundation
import Testing
@testable import KClip

@MainActor
@Suite("TrayPreviewPanelRegressionTests")
struct TrayPreviewPanelRegressionTests {
  @Test
  func previewKeepsTrayAtRestingHeight() {
    let item = ClipboardItem(text: "preview")
    let interaction = TrayInteractionModel()
    interaction.presentPreview(item)

    let view = makeRootView(interaction: interaction)

    #expect(view.overlayActive)
    #expect(view.panelHeight == TrayPanelLayout.preferredSize.height)
  }

  private func makeRootView(interaction: TrayInteractionModel = TrayInteractionModel()) -> TrayPanelRootView {
    TrayPanelRootView(
      panelWidth: TrayPanelLayout.preferredSize.width,
      store: ClipboardStore(fileURL: temporaryStoreURL()),
      linkPreviews: LinkPreviewStore(loader: NeverLoader()),
      interaction: interaction,
      isPermissionGranted: true,
      onClose: {},
      onPasteItem: { _ in },
      onRefocus: {},
      onOpenPermissions: {},
      onRestartPermissions: {}
    )
  }

  private func temporaryStoreURL() -> URL {
    URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
  }

  private final class NeverLoader: LinkPreviewLoading {
    func loadPreview(for url: URL, completion: @escaping (Result<LinkPreviewSnapshot, Error>) -> Void) {}
  }
}
