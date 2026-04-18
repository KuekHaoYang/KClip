import Foundation
@preconcurrency import WebKit

@MainActor
protocol LinkPreviewLoading {
  func loadPreview(for url: URL, completion: @escaping (Result<LinkPreviewSnapshot, Error>) -> Void)
}

@MainActor
final class LiveLinkPreviewLoader: LinkPreviewLoading {
  private var jobs: [String: LinkPreviewJob] = [:]

  func loadPreview(for url: URL, completion: @escaping (Result<LinkPreviewSnapshot, Error>) -> Void) {
    let key = url.absoluteString
    let job = LinkPreviewJob(url: url) { [weak self] result in
      self?.jobs[key] = nil
      completion(result)
    }
    jobs[key] = job
    job.start()
  }
}

@MainActor
private final class LinkPreviewJob: NSObject, WKNavigationDelegate {
  private let url: URL
  private let completion: (Result<LinkPreviewSnapshot, Error>) -> Void
  private let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 1200, height: 900))
  private var timeoutWorkItem: DispatchWorkItem?
  private var finished = false

  init(url: URL, completion: @escaping (Result<LinkPreviewSnapshot, Error>) -> Void) {
    self.url = url
    self.completion = completion
  }

  func start() {
    webView.navigationDelegate = self
    webView.load(URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 6))
    let workItem = DispatchWorkItem { [weak self] in self?.finish(.failure(LinkPreviewLoaderError.timeout)) }
    timeoutWorkItem = workItem
    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: workItem)
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in self?.capture() }
  }

  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { finish(.failure(error)) }
  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) { finish(.failure(error)) }

  private func capture() {
    let configuration = WKSnapshotConfiguration()
    configuration.rect = CGRect(origin: .zero, size: webView.bounds.size)
    webView.takeSnapshot(with: configuration) { [weak self] image, error in
      guard let self else { return }
      if let image { finish(.success(LinkPreviewSnapshot(url: url, title: webView.title, image: image))) }
      else if webView.title?.isEmpty == false { finish(.success(LinkPreviewSnapshot(url: url, title: webView.title))) }
      else { finish(.failure(error ?? LinkPreviewLoaderError.unavailable)) }
    }
  }

  private func finish(_ result: Result<LinkPreviewSnapshot, Error>) {
    guard finished == false else { return }
    finished = true
    timeoutWorkItem?.cancel()
    webView.stopLoading()
    completion(result)
  }
}

enum LinkPreviewLoaderError: Error {
  case unavailable
  case timeout
}
