import AppKit
import SwiftUI

struct ColorEditorPaletteView: View {
  @Binding var text: String
  let snippet: ColorSnippet
  @State private var selectedIndex = 0
  @State private var pickerColor = Color.white
  @State private var isSyncingPicker = false

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      ColorPaletteSurfaceView(snippet: snippet, compact: false).frame(height: 128)
      HStack(spacing: 10) {
        Picker("Swatch", selection: $selectedIndex) {
          ForEach(snippet.samples) { sample in Text(sample.displayCode).tag(sample.id) }
        }
        .pickerStyle(.menu)
        .labelsHidden()
        ColorPicker("", selection: $pickerColor, supportsOpacity: true).labelsHidden()
        Text(selectedSample.displayCode)
          .font(.system(size: 11, weight: .bold, design: .monospaced))
          .foregroundStyle(Color.white.opacity(0.78))
      }
    }
    .onAppear(perform: syncPicker)
    .onChange(of: selectedIndex) { _, _ in syncPicker() }
    .onChange(of: pickerColor) { _, value in handlePickerChange(value) }
    .onChange(of: snippet.samples.map(\.displayCode).joined(separator: ",")) { _, _ in
      clampSelection()
      syncPicker()
    }
    .animation(.spring(response: 0.24, dampingFraction: 0.84), value: selectedIndex)
    .animation(.spring(response: 0.24, dampingFraction: 0.84), value: snippet.samples.map(\.displayCode).joined(separator: ","))
  }

  private var currentIndex: Int { min(selectedIndex, max(snippet.samples.count - 1, 0)) }
  private var selectedSample: ColorSample { snippet.samples[currentIndex] }

  private func handlePickerChange(_ color: Color) {
    if isSyncingPicker {
      isSyncingPicker = false
      return
    }
    applyColor(color)
  }

  private func applyColor(_ color: Color) {
    guard let resolved = NSColor(color).usingColorSpace(.sRGB) else { return }
    guard let updated = snippet.updatingSample(
      at: currentIndex,
      red: resolved.redComponent,
      green: resolved.greenComponent,
      blue: resolved.blueComponent,
      alpha: resolved.alphaComponent
    ) else { return }
    text = updated
  }

  private func clampSelection() {
    selectedIndex = currentIndex
  }

  private func syncPicker() {
    clampSelection()
    isSyncingPicker = true
    pickerColor = selectedSample.swiftUIColor
  }
}
