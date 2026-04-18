import AppKit
import Foundation
import UniformTypeIdentifiers

@MainActor
final class ScreenshotMonitor {
  private let store: ClipboardStore
  private let directoryURL: URL
  private let filePrefix: String
  private var timer: Timer?
  private var knownPaths = Set<String>()

  init(
    store: ClipboardStore,
    directoryURL: URL = AppPaths.screenshotDirectoryURL,
    filePrefix: String = AppPaths.screenshotNamePrefix
  ) {
    self.store = store
    self.directoryURL = directoryURL
    self.filePrefix = filePrefix
  }

  func start() {
    guard timer == nil else { return }
    knownPaths = Set(candidateURLs.map(\.path))
    timer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { [weak self] _ in
      Task { @MainActor in self?.scan() }
    }
  }

  func stop() {
    timer?.invalidate()
    timer = nil
  }

  func scan() {
    candidateURLs
      .filter { knownPaths.contains($0.path) == false }
      .sorted(by: modifiedAt)
      .forEach(importIfReady)
  }

  private var candidateURLs: [URL] {
    let keys: Set<URLResourceKey> = [.contentModificationDateKey, .isRegularFileKey]
    let urls = (try? FileManager.default.contentsOfDirectory(
      at: directoryURL,
      includingPropertiesForKeys: Array(keys),
      options: [.skipsHiddenFiles]
    )) ?? []
    return urls.filter(isScreenshotImage)
  }

  private func isScreenshotImage(_ url: URL) -> Bool {
    let isImage = UTType(filenameExtension: url.pathExtension)?.conforms(to: .image) == true
    let isRegular = (try? url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) ?? false
    return isImage && isRegular && url.deletingPathExtension().lastPathComponent.hasPrefix(filePrefix)
  }

  private func importIfReady(_ url: URL) {
    guard let image = NSImage(contentsOf: url), let data = ImageDataNormalizer.pngData(from: image) else { return }
    knownPaths.insert(url.path)
    store.record(imageData: data, sourceAppName: "Screenshot")
  }

  private func modifiedAt(_ lhs: URL, _ rhs: URL) -> Bool {
    date(for: lhs) < date(for: rhs)
  }

  private func date(for url: URL) -> Date {
    (try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
  }
}
