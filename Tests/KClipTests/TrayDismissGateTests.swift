import Foundation
import Testing
@testable import KClip

@Suite("TrayDismissGateTests")
struct TrayDismissGateTests {
  @Test
  func ignoresDismissRightAfterToggle() {
    let now = Date(timeIntervalSince1970: 100)
    let toggleAt = Date(timeIntervalSince1970: 99.95)

    #expect(TrayDismissGate.shouldIgnoreDismiss(lastToggleAt: toggleAt, now: now))
  }

  @Test
  func allowsDismissAfterSuppressionWindow() {
    let now = Date(timeIntervalSince1970: 100)
    let toggleAt = Date(timeIntervalSince1970: 99.6)

    #expect(TrayDismissGate.shouldIgnoreDismiss(lastToggleAt: toggleAt, now: now) == false)
  }
}
