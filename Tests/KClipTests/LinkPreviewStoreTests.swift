import Foundation
import Testing
@testable import KClip

@MainActor
@Suite("LinkPreviewStoreTests")
struct LinkPreviewStoreTests {
  @Test
  func warmsLinkItemsAndCachesResolvedPreview() {
    let loader = LoaderStub()
    let store = LinkPreviewStore(loader: loader)
    let item = ClipboardItem(text: "https://example.com/articles/ship-fast")
    let url = try! #require(item.linkURL)

    store.warm([item])

    #expect(loader.urls == [url])
    #expect(store.model(for: item)?.phase == .loading)

    loader.succeed(url: url, title: "Ship Fast")

    #expect(store.model(for: item)?.phase == .ready)
    #expect(store.model(for: item)?.title == "Ship Fast")
    store.warm([item])
    #expect(loader.urls == [url])
  }

  @Test
  func ignoresPlainTextItems() {
    let loader = LoaderStub()
    let store = LinkPreviewStore(loader: loader)

    store.warm([ClipboardItem(text: "plain text")])

    #expect(loader.urls.isEmpty)
  }

  private final class LoaderStub: LinkPreviewLoading {
    var urls: [URL] = []
    var completions: [String: (Result<LinkPreviewSnapshot, Error>) -> Void] = [:]

    func loadPreview(for url: URL, completion: @escaping (Result<LinkPreviewSnapshot, Error>) -> Void) {
      urls.append(url)
      completions[url.absoluteString] = completion
    }

    func succeed(url: URL, title: String) {
      completions[url.absoluteString]?(.success(LinkPreviewSnapshot(url: url, title: title)))
    }
  }
}
