import AppKit
import Foundation

@MainActor
final class ClipboardMonitor {
  private let pasteboard = NSPasteboard.general
  private let store: ClipboardStore
  private let applicationTracker: LastActiveApplicationTracker
  private var timer: Timer?
  private var changeCount: Int

  init(
    store: ClipboardStore,
    applicationTracker: LastActiveApplicationTracker = LastActiveApplicationTracker()
  ) {
    self.store = store
    self.applicationTracker = applicationTracker
    self.changeCount = pasteboard.changeCount
  }

  func start() {
    guard timer == nil else { return }
    timer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { [weak self] _ in
      Task { @MainActor in
        self?.captureIfNeeded()
      }
    }
  }

  func stop() {
    timer?.invalidate()
    timer = nil
  }

  private func captureIfNeeded() {
    guard pasteboard.changeCount != changeCount else { return }
    changeCount = pasteboard.changeCount
    let source = applicationTracker.currentTarget()
    switch ClipboardCaptureReader.capture(from: pasteboard) {
    case .text(let text):
      store.record(text: text, sourceAppName: source?.localizedName, sourceBundleID: source?.bundleIdentifier)
    case .image(let data):
      store.record(imageData: data, sourceAppName: source?.localizedName, sourceBundleID: source?.bundleIdentifier)
    case nil:
      return
    }
  }
}
