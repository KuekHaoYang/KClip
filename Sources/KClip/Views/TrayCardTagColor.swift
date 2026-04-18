import SwiftUI

extension ClipboardItem {
  var trayCardTagColor: Color {
    switch primaryTag {
    case .pinned: Color(red: 0.98, green: 0.80, blue: 0.46)
    case .general: Color.white.opacity(0.72)
    case .code: Color(red: 0.58, green: 0.78, blue: 1.00)
    case .link: Color(red: 0.58, green: 0.90, blue: 0.94)
    case .note: Color(red: 0.66, green: 0.90, blue: 0.70)
    case .color: Color(red: 1.00, green: 0.78, blue: 0.46)
    case .image: Color(red: 0.96, green: 0.72, blue: 0.86)
    }
  }
}
