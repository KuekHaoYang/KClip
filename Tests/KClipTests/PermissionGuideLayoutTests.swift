import CoreGraphics
import Testing
@testable import KClip

@Suite("PermissionGuideLayoutTests")
struct PermissionGuideLayoutTests {
  @Test
  func placesGuideAboveTrayWithinVisibleBounds() {
    let visible = CGRect(x: 0, y: 0, width: 1280, height: 800)
    let tray = CGRect(x: 200, y: 24, width: 860, height: 250)

    let frame = PermissionGuideLayout.frame(trayFrame: tray, visibleFrame: visible)

    #expect(frame.minY >= tray.maxY)
    #expect(frame.minX >= visible.minX)
    #expect(frame.maxX <= visible.maxX)
    #expect(frame.maxY <= visible.maxY)
  }
}
