import SwiftUI

struct TrayEditorStageView: View {
  let item: ClipboardItem
  @Binding var text: String
  let onCancel: () -> Void
  let onSave: () -> Void

  var body: some View {
    ZStack(alignment: .bottom) {
      Color.black.opacity(0.18)
        .frame(maxWidth: .infinity)
        .frame(height: TrayPanelLayout.trayContentHeight)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .transition(.opacity)
      ClipEditorOverlayView(item: item, text: $text, onCancel: onCancel, onSave: onSave)
        .padding(.bottom, TrayPanelLayout.overlayBottomInset)
        .transition(
          .asymmetric(
            insertion: .offset(y: 20).combined(with: .opacity).combined(with: .scale(scale: 0.96)),
            removal: .offset(y: 12).combined(with: .opacity)
          )
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
  }
}
