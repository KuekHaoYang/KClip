import CoreGraphics
import Testing
@testable import KClip

@Suite("TrayPanelLayoutTests")
struct TrayPanelLayoutTests {
  @Test
  func centersTrayAtBottomOfVisibleFrame() {
    let visibleFrame = CGRect(x: 100, y: 50, width: 1200, height: 800)
    let size = CGSize(width: 720, height: 240)

    let frame = TrayPanelLayout.frame(in: visibleFrame, panelSize: size)

    #expect(frame.origin.x == 340)
    #expect(frame.origin.y == 74)
    #expect(frame.size == size)
  }

  @Test
  func clampsTrayWidthToVisibleFrameWithMargins() {
    let visibleFrame = CGRect(x: 0, y: 0, width: 700, height: 500)
    let size = CGSize(width: 900, height: 240)

    let frame = TrayPanelLayout.frame(in: visibleFrame, panelSize: size)

    #expect(frame.width == 664)
    #expect(frame.origin.x == 18)
    #expect(frame.origin.y == 24)
  }

  @Test
  func derivesAnimatedEntryFrameFromFinalFrame() {
    let finalFrame = CGRect(x: 326, y: 108, width: 860, height: 250)

    let entryFrame = TrayPanelLayout.entryFrame(for: finalFrame)

    #expect(entryFrame.width == 808.4)
    #expect(entryFrame.height == 235)
    #expect(entryFrame.origin.x == 351.8)
    #expect(entryFrame.origin.y == 90.5)
  }

  @Test
  func expandedPanelAddsHeadroomWithoutMovingTheTrayFloor() {
    #expect(TrayPanelLayout.expandedHeight > TrayPanelLayout.preferredSize.height)
    #expect(TrayPanelLayout.trayContentHeight < TrayPanelLayout.preferredSize.height)
    #expect(TrayPanelLayout.overlayBottomInset < TrayPanelLayout.trayContentHeight)
  }

  @Test
  func restingPanelKeepsExtraTopSlackAboveTraySurface() {
    #expect(TrayPanelLayout.trayContentHeight >= 268)
    #expect(TrayPanelLayout.preferredSize.height - TrayPanelLayout.trayContentHeight >= 32)
  }
}
