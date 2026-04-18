import AppKit

enum TrayKeyCommand: Equatable {
  case move(Int)
  case pasteSelection
  case quickPaste(Int)
  case togglePreview
  case close

  init?(event: NSEvent) {
    let modifiers = Self.normalizedModifiers(for: event)
    if modifiers.isEmpty {
      switch event.keyCode {
      case 36, 76: self = .pasteSelection
      case 49: self = .togglePreview
      case 53: self = .close
      case 123, 126: self = .move(-1)
      case 124, 125: self = .move(1)
      default: return nil
      }
      return
    }

    guard modifiers == .command, let chars = event.charactersIgnoringModifiers else { return nil }
    guard let number = Int(chars), (1 ... 9).contains(number) else { return nil }
    self = .quickPaste(number)
  }

  private static func normalizedModifiers(for event: NSEvent) -> NSEvent.ModifierFlags {
    event.modifierFlags.intersection(.deviceIndependentFlagsMask).subtracting([.numericPad, .function])
  }
}
