import Foundation
import Observation

@MainActor
@Observable
final class LinkPreviewStore {
  private(set) var models: [String: LinkPreviewSnapshot] = [:]
  private let loader: LinkPreviewLoading
  private var inFlight = Set<String>()

  init(loader: LinkPreviewLoading = LiveLinkPreviewLoader()) {
    self.loader = loader
  }

  func model(for item: ClipboardItem) -> LinkPreviewSnapshot? {
    guard let url = item.linkURL else { return nil }
    return models[url.absoluteString] ?? .loading(url: url)
  }

  func warm(_ items: [ClipboardItem]) {
    items.compactMap(\.linkURL).forEach(request)
  }

  private func request(_ url: URL) {
    let key = url.absoluteString
    guard inFlight.contains(key) == false, models[key]?.phase != .ready, models[key]?.phase != .failed else { return }
    inFlight.insert(key)
    models[key] = models[key] ?? .loading(url: url)
    loader.loadPreview(for: url) { [weak self] result in
      self?.finish(try? result.get(), key: key, url: url)
    }
  }

  private func finish(_ preview: LinkPreviewSnapshot?, key: String, url: URL) {
    inFlight.remove(key)
    models[key] = preview ?? .failed(url: url)
  }
}
