import SwiftUI

struct TraySearchBarView: View {
  @Binding var searchText: String
  @Binding var isPresented: Bool
  let resultLabel: String
  @FocusState private var isFocused: Bool

  var body: some View {
    HStack(spacing: 10) {
      button("magnifyingglass", action: toggle)
      if isPresented {
        TextField("Search clips", text: $searchText)
          .textFieldStyle(.plain)
          .font(.system(size: 12, weight: .medium, design: .rounded))
          .focused($isFocused)
          .transition(.move(edge: .trailing).combined(with: .opacity))
        Text(resultLabel)
          .font(.system(size: 10, weight: .semibold, design: .rounded))
          .foregroundStyle(Color.white.opacity(0.52))
          .padding(.horizontal, 10)
          .padding(.vertical, 6)
          .background(Capsule().fill(Color.white.opacity(0.06)))
          .transition(.opacity.combined(with: .scale(scale: 0.94)))
        button("xmark.circle.fill", action: clearOrCollapse, isSecondary: true)
          .transition(.opacity.combined(with: .scale(scale: 0.86)))
      }
    }
    .frame(maxWidth: .infinity, alignment: isPresented ? .leading : .center)
    .frame(width: isPresented ? 304 : 42, height: 42)
    .padding(.leading, isPresented ? 12 : 0)
    .padding(.trailing, isPresented ? 10 : 0)
    .background(Capsule().fill(Color.white.opacity(0.08)))
    .overlay(Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1))
    .contentShape(Capsule())
    .onTapGesture { isPresented ? (isFocused = true) : toggle() }
    .animation(.spring(response: 0.28, dampingFraction: 0.84), value: isPresented)
    .animation(.easeOut(duration: 0.16), value: resultLabel)
    .onChange(of: isPresented) { _, newValue in if newValue { isFocused = true } }
    .onChange(of: isFocused) { _, focused in if focused == false && searchText.isEmpty { isPresented = false } }
  }

  private func toggle() {
    withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
      isPresented.toggle()
      if isPresented == false { searchText = "" }
    }
  }

  private func clearOrCollapse() {
    if searchText.isEmpty {
      withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) { isPresented = false }
      return
    }
    searchText = ""
  }

  private func button(_ name: String, action: @escaping () -> Void, isSecondary: Bool = false) -> some View {
    Button(action: action) {
      Image(systemName: name)
        .font(.system(size: 15, weight: .semibold))
        .foregroundStyle(isSecondary ? .secondary : .primary)
        .frame(width: 20, height: 20, alignment: .center)
    }
    .buttonStyle(.plain)
  }
}
