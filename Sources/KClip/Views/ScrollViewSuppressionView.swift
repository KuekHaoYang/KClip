import AppKit
import SwiftUI

struct ScrollViewSuppressionView: NSViewRepresentable {
  final class Coordinator {
    let scrollViews = NSHashTable<NSScrollView>.weakObjects()
    var revision = 0
  }

  func makeCoordinator() -> Coordinator { Coordinator() }
  func makeNSView(context: Context) -> NSView { NSView(frame: .zero) }

  func updateNSView(_ nsView: NSView, context: Context) {
    context.coordinator.revision += 1
    let revision = context.coordinator.revision
    [0.0, 0.05, 0.15, 0.35].forEach {
      scheduleSuppressionSweep(after: $0, from: nsView, coordinator: context.coordinator, revision: revision)
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

  private func scheduleSuppressionSweep(
    after delay: Double,
    from view: NSView,
    coordinator: Coordinator,
    revision: Int
  ) {
    let sweep = {
      guard coordinator.revision == revision else { return }
      allScrollViews(in: rootView(for: view)).forEach { scrollView in
        coordinator.scrollViews.add(scrollView)
        if isSuppressed(scrollView) == false { suppress(scrollView) }
      }
    }
    if delay == 0 { DispatchQueue.main.async { sweep() } }
    else { DispatchQueue.main.asyncAfter(deadline: .now() + delay) { sweep() } }
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
