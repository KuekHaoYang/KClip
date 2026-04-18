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
      let frame = targetFrame(for: window)
      guard abs(window.frame.width - frame.width) > 0.5 || abs(window.frame.height - frame.height) > 0.5 else { return }
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

  private func targetFrame(for window: NSWindow) -> CGRect {
    let visibleFrame = window.screen?.visibleFrame ?? NSScreen.main?.visibleFrame ?? window.frame
    var frame = window.frame
    frame.size.width = size.width
    frame.size.height = min(size.height, visibleFrame.maxY - frame.minY)
    return frame
  }
}
