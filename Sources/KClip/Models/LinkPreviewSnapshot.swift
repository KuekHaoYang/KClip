import AppKit
import Foundation

struct LinkPreviewSnapshot {
  enum Phase: Equatable { case loading, ready, failed }

  let url: URL
  let title: String
  let host: String
  let phase: Phase
  let image: NSImage?
  let displayImage: NSImage?

  init(url: URL, title: String? = nil, phase: Phase = .ready, image: NSImage? = nil) {
    let cleanTitle = title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    self.url = url
    self.host = url.host?.replacingOccurrences(of: "www.", with: "") ?? url.absoluteString
    self.title = cleanTitle.isEmpty ? self.host : cleanTitle
    self.phase = phase
    self.image = image
    self.displayImage = LinkPreviewImageAnalyzer.displayImage(from: image)
  }

  static func loading(url: URL) -> LinkPreviewSnapshot {
    LinkPreviewSnapshot(url: url, phase: .loading)
  }

  static func failed(url: URL) -> LinkPreviewSnapshot {
    LinkPreviewSnapshot(url: url, phase: .failed)
  }

  var subtitle: String {
    switch phase {
    case .loading: "Fetching web page preview"
    case .failed: "Preview unavailable"
    case .ready: title == host ? "Web page preview" : host
    }
  }

  var badge: String {
    switch phase {
    case .loading: "Loading"
    case .failed: "Unavailable"
    case .ready: "Web Page"
    }
  }
}
