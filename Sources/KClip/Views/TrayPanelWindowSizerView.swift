import AppKit
import SwiftUI

struct TrayPanelWindowSizerView: NSViewRepresentable {
  let size: CGSize
  let animated: Bool

  func makeNSView(context: Context) -> NSView {
    NSView()
  }

  func updateNSView(_ view: NSView, context: Context) {
    DispatchQueue.main.async {
      guard let window = view.window else { return }
      guard abs(window.frame.width - size.width) > 0.5 || abs(window.frame.height - size.height) > 0.5 else { return }
      var frame = window.frame
      frame.size = size
      if animated {
        NSAnimationContext.runAnimationGroup { context in
          context.duration = 0.18
          window.animator().setFrame(frame, display: true)
        }
      } else {
        window.setFrame(frame, display: true)
      }
    }
  }
}
