import SwiftUI

struct TagChipView: View {
  let tag: ClipTag
  let isSelected: Bool

  var body: some View {
    HStack(spacing: 7) {
      Circle().fill(accentColor.opacity(isSelected ? 0.92 : 0.68)).frame(width: 7, height: 7)
      Text(tag.title).font(.system(size: 11, weight: .semibold, design: .rounded))
    }
    .padding(.horizontal, 11)
    .padding(.vertical, 7)
    .background(Capsule().fill(isSelected ? Color.white.opacity(0.14) : Color.white.opacity(0.06)))
    .overlay(Capsule().stroke(isSelected ? accentColor.opacity(0.42) : Color.white.opacity(0.08), lineWidth: 1))
  }

  private var accentColor: Color {
    switch tag {
    case .pinned: Color(red: 0.98, green: 0.80, blue: 0.46)
    case .general: Color.white.opacity(0.76)
    case .code: Color(red: 0.42, green: 0.68, blue: 1.00)
    case .link: Color(red: 0.40, green: 0.86, blue: 0.86)
    case .note: Color(red: 0.54, green: 0.84, blue: 0.60)
    case .color: Color(red: 1.00, green: 0.74, blue: 0.36)
    case .image: Color(red: 0.94, green: 0.60, blue: 0.78)
    }
  }
}
