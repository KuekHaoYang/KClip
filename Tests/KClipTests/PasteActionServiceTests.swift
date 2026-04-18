import Testing
@testable import KClip

@Suite("PasteActionServiceTests")
struct PasteActionServiceTests {
  @Test
  func writesTextBeforeSendingPaste() {
    var events: [String] = []
    let service = PasteActionService(
      writeText: { events.append("write:\($0)") },
      sendPaste: { events.append("paste") }
    )

    #expect(service.performPaste(text: "hello"))
    #expect(events == ["write:hello", "paste"])
  }

  @Test
  func ignoresEmptyText() {
    var called = false
    let service = PasteActionService(
      writeText: { _ in called = true },
      sendPaste: { called = true }
    )

    #expect(service.performPaste(text: "") == false)
    #expect(called == false)
  }
}
