import SwiftUI

struct TrayPreviewStageView: View {
  let item: ClipboardItem
  let linkPreviews: LinkPreviewStore
  let onClose: () -> Void

  var body: some View {
    ZStack(alignment: .bottom) {
      Color.black.opacity(0.18)
        .frame(maxWidth: .infinity)
        .frame(height: TrayPanelLayout.trayContentHeight)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .onTapGesture(perform: onClose)
        .transition(.opacity)
      ClipPreviewOverlayView(item: item, linkPreviews: linkPreviews, onClose: onClose)
        .padding(.bottom, TrayPanelLayout.overlayBottomInset)
        .transition(.asymmetric(insertion: .offset(y: 18).combined(with: .opacity), removal: .opacity))
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
  }
}
