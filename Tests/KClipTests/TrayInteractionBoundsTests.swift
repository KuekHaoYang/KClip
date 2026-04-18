import CoreGraphics
import Testing
@testable import KClip

@Suite("TrayInteractionBoundsTests")
struct TrayInteractionBoundsTests {
  @Test
  func treatsPermissionGuideFrameAsInteractive() {
    let tray = CGRect(x: 300, y: 24, width: 860, height: 250)
    let guide = CGRect(x: 340, y: 288, width: 340, height: 214)

    #expect(
      TrayInteractionBounds.contains(
        CGPoint(x: 360, y: 320),
        trayFrame: tray,
        guideFrame: guide
      )
    )
  }

  @Test
  func rejectsPointsOutsideTrayAndGuide() {
    let tray = CGRect(x: 300, y: 24, width: 860, height: 250)
    let guide = CGRect(x: 340, y: 288, width: 340, height: 214)

    #expect(
      TrayInteractionBounds.contains(
        CGPoint(x: 1200, y: 620),
        trayFrame: tray,
        guideFrame: guide
      ) == false
    )
  }
}
