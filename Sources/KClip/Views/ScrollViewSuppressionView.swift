import AppKit
import SwiftUI

struct ScrollViewSuppressionView: NSViewRepresentable {
  final class Coordinator { let scrollViews = NSHashTable<NSScrollView>.weakObjects() }

  func makeCoordinator() -> Coordinator { Coordinator() }
  func makeNSView(context: Context) -> NSView { NSView(frame: .zero) }

  func updateNSView(_ nsView: NSView, context: Context) {
    DispatchQueue.main.async {
      allScrollViews(in: rootView(for: nsView)).forEach { scrollView in
        context.coordinator.scrollViews.add(scrollView)
        if isSuppressed(scrollView) == false { suppress(scrollView) }
      }
    }
  }

  private func rootView(for view: NSView) -> NSView {
    var current = view
    while let superview = current.superview { current = superview }
    return current
  }

  private func allScrollViews(in view: NSView) -> [NSScrollView] {
    let direct = (view as? NSScrollView).map { [$0] } ?? []
    return direct + view.subviews.flatMap(allScrollViews)
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
