import SwiftUI

final class TrayHostingView<Content: View>: NSHostingView<Content> {
  var onKeyDown: (NSEvent) -> Bool = { _ in false }

  override var acceptsFirstResponder: Bool { true }
  override var canBecomeKeyView: Bool { true }

  override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    window?.makeFirstResponder(self)
  }

  override func keyDown(with event: NSEvent) {
    onKeyDown(event) ? () : super.keyDown(with: event)
  }
}
