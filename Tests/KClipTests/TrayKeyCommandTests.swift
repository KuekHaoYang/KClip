import AppKit
import Testing
@testable import KClip

@Suite("TrayKeyCommandTests")
struct TrayKeyCommandTests {
  @Test
  func mapsReturnToPasteSelection() {
    #expect(TrayKeyCommand(event: event(chars: "\r", keyCode: 36)) == .pasteSelection)
  }

  @Test
  func mapsEscapeToClose() {
    #expect(TrayKeyCommand(event: event(chars: "\u{1b}", keyCode: 53)) == .close)
  }

  @Test
  func mapsArrowKeysToMovement() {
    #expect(TrayKeyCommand(event: event(chars: "", keyCode: 123)) == .move(-1))
    #expect(TrayKeyCommand(event: event(chars: "", keyCode: 124)) == .move(1))
  }

  @Test
  func mapsArrowKeysWithSystemFlagsToMovement() {
    let modifiers: NSEvent.ModifierFlags = [.numericPad, .function]
    #expect(TrayKeyCommand(event: event(chars: "", keyCode: 123, modifiers: modifiers)) == .move(-1))
    #expect(TrayKeyCommand(event: event(chars: "", keyCode: 124, modifiers: modifiers)) == .move(1))
  }

  @Test
  func mapsRepeatedArrowKeysToMovement() {
    #expect(TrayKeyCommand(event: event(chars: "", keyCode: 124, isARepeat: true)) == .move(1))
  }

  @Test
  func mapsCommandDigitsToQuickPaste() {
    let commandFive = event(chars: "5", keyCode: 23, modifiers: .command)
    #expect(TrayKeyCommand(event: commandFive) == .quickPaste(5))
  }

  @Test
  func mapsSpaceToPreviewToggle() {
    #expect(TrayKeyCommand(event: event(chars: " ", keyCode: 49)) == .togglePreview)
  }

  private func event(
    chars: String,
    keyCode: UInt16,
    modifiers: NSEvent.ModifierFlags = [],
    isARepeat: Bool = false
  ) -> NSEvent {
    NSEvent.keyEvent(
      with: .keyDown,
      location: .zero,
      modifierFlags: modifiers,
      timestamp: 0,
      windowNumber: 0,
      context: nil,
      characters: chars,
      charactersIgnoringModifiers: chars,
      isARepeat: isARepeat,
      keyCode: keyCode
    )!
  }
}
