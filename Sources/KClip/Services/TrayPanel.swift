import AppKit

final class TrayPanel: NSPanel {
  var onKeyDown: (NSEvent) -> Bool = { _ in false }

  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { false }

  override func keyDown(with event: NSEvent) {
    onKeyDown(event) ? () : super.keyDown(with: event)
  }
}
