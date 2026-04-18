import Testing
@testable import KClip

@Suite("TrayPreviewInteractionTests")
struct TrayPreviewInteractionTests {
  private let items = [ClipboardItem(text: "first"), ClipboardItem(text: "second")]

  @Test
  @MainActor
  func previewCommandTogglesSelectedClip() {
    let model = TrayInteractionModel()
    _ = model.activate(index: 1, items: items)

    #expect(model.handle(.togglePreview, items: items) == .none)
    #expect(model.previewItem?.text == "second")

    #expect(model.handle(.togglePreview, items: items) == .none)
    #expect(model.previewItem == nil)
  }

  @Test
  @MainActor
  func closeDismissesPreviewBeforeClosingTray() {
    let model = TrayInteractionModel()
    _ = model.activate(index: 1, items: items)
    _ = model.handle(.togglePreview, items: items)

    #expect(model.handle(.close, items: items) == .none)
    #expect(model.previewItem == nil)
  }

  @Test
  @MainActor
  func movingSelectionWhilePreviewIsOpenSwitchesPreviewedClip() {
    let model = TrayInteractionModel()
    _ = model.activate(index: 0, items: items)
    _ = model.handle(.togglePreview, items: items)

    #expect(model.handle(.move(1), items: items) == .none)
    #expect(model.selection.index == 1)
    #expect(model.previewItem?.text == "second")

    #expect(model.handle(.togglePreview, items: items) == .none)
    #expect(model.previewItem == nil)
  }
}
