import LinkPresentation
import SwiftUI

struct LinkPreviewRepresentable: NSViewRepresentable {
  let preview: LinkPreviewSnapshot

  func makeNSView(context: Context) -> LPLinkView {
    let metadata = LPLinkMetadata()
    metadata.originalURL = preview.url
    metadata.url = preview.url
    metadata.title = preview.title
    return LPLinkView(metadata: metadata)
  }

  func updateNSView(_ nsView: LPLinkView, context: Context) {}
}
