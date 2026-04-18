import SwiftUI

struct TrayTagStripView: View {
  let tags: [ClipTag]
  @ObservedObject var interaction: TrayInteractionModel

  var body: some View {
    ScrollView(.horizontal) {
      HStack(spacing: 8) {
        allChip
        ForEach(tags) { tag in
          Button { interaction.toggleTag(tag) } label: {
            TagChipView(tag: tag, isSelected: interaction.selectedTag == tag)
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.horizontal, 2)
    }
    .scrollIndicators(.hidden)
  }

  private var allChip: some View {
    Button { interaction.selectedTag = nil } label: {
      Text("All")
        .font(.system(size: 11, weight: .semibold, design: .rounded))
        .padding(.horizontal, 11)
        .padding(.vertical, 7)
        .background(Capsule().fill(interaction.selectedTag == nil ? Color.white.opacity(0.14) : Color.white.opacity(0.06)))
        .overlay(Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
    .buttonStyle(.plain)
  }
}
