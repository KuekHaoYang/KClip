import AppKit
import SwiftUI

struct ScrollViewSuppressionView: NSViewRepresentable {
  final class Coordinator { weak var scrollView: NSScrollView? }

  func makeCoordinator() -> Coordinator { Coordinator() }
  func makeNSView(context: Context) -> NSView { NSView(frame: .zero) }

  func updateNSView(_ nsView: NSView, context: Context) {
    if isSuppressed(context.coordinator.scrollView) { return }
    DispatchQueue.main.async {
      if isSuppressed(context.coordinator.scrollView) { return }
      guard let scrollView = firstScrollView(in: rootView(for: nsView)) else { return }
      context.coordinator.scrollView = scrollView
      suppress(scrollView)
    }
  }

  private func rootView(for view: NSView) -> NSView {
    var current = view
    while let superview = current.superview { current = superview }
    return current
  }

  private func firstScrollView(in view: NSView) -> NSScrollView? {
    if let scrollView = view as? NSScrollView { return scrollView }
    for subview in view.subviews {
      if let scrollView = firstScrollView(in: subview) { return scrollView }
    }
    return nil
  }

  private func isSuppressed(_ scrollView: NSScrollView?) -> Bool {
    guard let scrollView, scrollView.window != nil else { return false }
    return scrollView.hasHorizontalScroller == false
      && scrollView.hasVerticalScroller == false
      && scrollView.horizontalScroller == nil
      && scrollView.verticalScroller == nil
  }

  private func suppress(_ scrollView: NSScrollView) {
    scrollView.hasHorizontalScroller = false
    scrollView.hasVerticalScroller = false
    scrollView.horizontalScroller = nil
    scrollView.verticalScroller = nil
    scrollView.autohidesScrollers = true
    scrollView.scrollerStyle = .overlay
    scrollView.tile()
    hideScrollers(in: scrollView)
  }

  private func hideScrollers(in view: NSView) {
    if let scroller = view as? NSScroller {
      scroller.isHidden = true
      scroller.alphaValue = 0
    }
    view.subviews.forEach(hideScrollers)
  }
}
