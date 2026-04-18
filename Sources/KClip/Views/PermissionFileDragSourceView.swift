import AppKit
import SwiftUI

struct PermissionFileDragSourceView: NSViewRepresentable {
  let bundleURL: URL

  func makeNSView(context: Context) -> PermissionFileDragNSView {
    let view = PermissionFileDragNSView()
    view.configure(bundleURL: bundleURL)
    return view
  }

  func updateNSView(_ nsView: PermissionFileDragNSView, context: Context) {
    nsView.configure(bundleURL: bundleURL)
  }
}

final class PermissionFileDragNSView: NSView, NSDraggingSource {
  private var bundleURL = URL(fileURLWithPath: "/")
  private var mouseDownEvent: NSEvent?
  private var didStartDrag = false

  override var isOpaque: Bool { false }

  func configure(bundleURL: URL) {
    self.bundleURL = bundleURL
  }

  override func mouseDown(with event: NSEvent) {
    mouseDownEvent = event
    didStartDrag = false
  }

  override func mouseDragged(with event: NSEvent) {
    guard didStartDrag == false, let mouseDownEvent else { return }
    didStartDrag = true
    let item = NSDraggingItem(pasteboardWriter: bundleURL as NSURL)
    let icon = NSWorkspace.shared.icon(forFile: bundleURL.path)
    icon.size = NSSize(width: 44, height: 44)
    item.setDraggingFrame(dragFrame, contents: icon)
    beginDraggingSession(with: [item], event: mouseDownEvent, source: self)
  }

  func draggingSession(
    _ session: NSDraggingSession,
    sourceOperationMaskFor context: NSDraggingContext
  ) -> NSDragOperation {
    .copy
  }

  func ignoreModifierKeys(for session: NSDraggingSession) -> Bool {
    true
  }

  private var dragFrame: CGRect {
    CGRect(x: (bounds.width - 44) / 2, y: (bounds.height - 44) / 2, width: 44, height: 44)
  }
}
