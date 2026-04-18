import SwiftUI

struct TrayPreviewStageView: View {
  let item: ClipboardItem
  let linkPreviews: LinkPreviewStore
  let onClose: () -> Void

  var body: some View {
    ZStack {
      Color.black.opacity(0.18)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .onTapGesture(perform: onClose)
        .transition(.opacity)
      ClipPreviewOverlayView(item: item, linkPreviews: linkPreviews, onClose: onClose)
        .padding(.top, 6)
        .transition(.asymmetric(insertion: .offset(y: 18).combined(with: .opacity), removal: .opacity))
    }
  }
}
