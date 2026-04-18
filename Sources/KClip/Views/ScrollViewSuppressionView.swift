import AppKit
import SwiftUI

struct ScrollViewSuppressionView: NSViewRepresentable {
  func makeNSView(context: Context) -> NSView { NSView(frame: .zero) }

  func updateNSView(_ nsView: NSView, context: Context) {
    DispatchQueue.main.async {
      suppressScrollers(in: rootView(for: nsView))
    }
  }

  private func rootView(for view: NSView) -> NSView {
    var current = view
    while let superview = current.superview { current = superview }
    return current
  }

  private func suppressScrollers(in view: NSView) {
    if let scrollView = view as? NSScrollView {
      scrollView.hasHorizontalScroller = false
      scrollView.hasVerticalScroller = false
      scrollView.horizontalScroller = nil
      scrollView.verticalScroller = nil
      scrollView.autohidesScrollers = true
      scrollView.scrollerStyle = .overlay
      scrollView.tile()
    }
    if let scroller = view as? NSScroller {
      scroller.isHidden = true
      scroller.alphaValue = 0
    }
    view.subviews.forEach(suppressScrollers)
  }
}
