import Testing
@testable import KClip

@Suite("PasteHandoffCoordinatorTests")
struct PasteHandoffCoordinatorTests {
  @Test
  func sendsImmediatelyWhenTargetIsAlreadyFrontmost() {
    var sent = 0
    var retries: [() -> Void] = []
    let coordinator = PasteHandoffCoordinator(
      frontmostBundleID: { "com.apple.TextEdit" },
      schedule: { _, work in retries.append(work) }
    )

    coordinator.sendWhenReady(targetBundleID: "com.apple.TextEdit") { sent += 1 }
    #expect(sent == 0)
    #expect(retries.count == 1)
    retries.removeFirst()()
    #expect(sent == 1)
  }

  @Test
  func waitsUntilFrontmostAppMatchesTarget() {
    var frontmost = "com.kuekhaoyang.kclip"
    var retries: [() -> Void] = []
    var sent = 0
    var activations = 0
    let coordinator = PasteHandoffCoordinator(
      frontmostBundleID: { frontmost },
      schedule: { _, work in retries.append(work) }
    )

    coordinator.sendWhenReady(
      targetBundleID: "com.apple.TextEdit",
      activateTarget: { activations += 1 }
    ) { sent += 1 }
    #expect(sent == 0)
    #expect(activations == 1)
    #expect(retries.count == 1)
    frontmost = "com.apple.TextEdit"
    retries.removeFirst()()
    #expect(sent == 0)
    #expect(retries.count == 1)
    retries.removeFirst()()
    #expect(sent == 1)
  }
}
