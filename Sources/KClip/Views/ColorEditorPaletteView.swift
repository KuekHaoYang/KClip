import AppKit
import SwiftUI

struct ColorEditorPaletteView: View {
  @Binding var text: String
  let snippet: ColorSnippet
  @State private var selectedIndex = 0
  @State private var pickerColor = Color.white

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      ColorPreviewSummaryView(snippet: snippet, compact: false).frame(height: 148)
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) { ForEach(snippet.samples) { chip($0) } }
      }
      HStack(spacing: 10) {
        Text("Palette").font(.system(size: 11, weight: .bold, design: .rounded))
        ColorPicker("", selection: $pickerColor, supportsOpacity: true).labelsHidden()
        Text(selectedSample.displayCode)
          .font(.system(size: 11, weight: .bold, design: .monospaced))
          .foregroundStyle(Color.white.opacity(0.78))
      }
    }
    .onAppear(perform: syncPicker)
    .onChange(of: selectedIndex) { _, _ in syncPicker() }
    .onChange(of: pickerColor) { _, value in applyColor(value) }
    .onChange(of: snippet.samples.map(\.displayCode).joined(separator: ",")) { _, _ in
      clampSelection()
      syncPicker()
    }
    .animation(.spring(response: 0.24, dampingFraction: 0.84), value: selectedIndex)
    .animation(.spring(response: 0.24, dampingFraction: 0.84), value: snippet.samples.map(\.displayCode).joined(separator: ","))
  }

  private var currentIndex: Int { min(selectedIndex, max(snippet.samples.count - 1, 0)) }
  private var selectedSample: ColorSample { snippet.samples[currentIndex] }

  private func chip(_ sample: ColorSample) -> some View {
    let isSelected = sample.id == selectedSample.id
    return Button { selectedIndex = sample.id } label: {
      HStack(spacing: 8) {
        Circle().fill(sample.swiftUIColor).frame(width: 14, height: 14)
        Text(sample.displayCode).lineLimit(1)
      }
      .font(.system(size: 10, weight: .bold, design: .monospaced))
      .padding(.horizontal, 10)
      .padding(.vertical, 7)
      .background(Capsule().fill(Color.white.opacity(isSelected ? 0.16 : 0.08)))
      .overlay(Capsule().stroke(Color.white.opacity(isSelected ? 0.18 : 0.10), lineWidth: 1))
    }
    .buttonStyle(.plain)
  }

  private func applyColor(_ color: Color) {
    guard let resolved = NSColor(color).usingColorSpace(.sRGB) else { return }
    let code = ColorSample.code(
      red: resolved.redComponent,
      green: resolved.greenComponent,
      blue: resolved.blueComponent,
      alpha: resolved.alphaComponent
    )
    text = snippet.replacingSample(at: currentIndex, with: code)
  }

  private func clampSelection() {
    selectedIndex = currentIndex
  }

  private func syncPicker() {
    clampSelection()
    pickerColor = selectedSample.swiftUIColor
  }
}
