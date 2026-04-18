import Foundation
@preconcurrency import LinkPresentation

protocol LinkPreviewLoading {
  func loadPreview(for url: URL, completion: @escaping @Sendable (Result<LinkPreviewSnapshot, Error>) -> Void)
}

final class LiveLinkPreviewLoader: LinkPreviewLoading {
  func loadPreview(for url: URL, completion: @escaping @Sendable (Result<LinkPreviewSnapshot, Error>) -> Void) {
    let provider = LPMetadataProvider()
    provider.timeout = 3
    provider.startFetchingMetadata(for: url) { metadata, error in
      _ = provider
      if let metadata {
        let resolvedURL = metadata.originalURL ?? metadata.url ?? url
        completion(.success(LinkPreviewSnapshot(url: resolvedURL, title: metadata.title)))
      } else {
        completion(.failure(error ?? LinkPreviewLoaderError.unavailable))
      }
    }
  }
}

enum LinkPreviewLoaderError: Error {
  case unavailable
}
