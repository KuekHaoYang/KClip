import Testing
@testable import KClip

@Suite("AccessibilityPermissionServiceTests")
struct AccessibilityPermissionServiceTests {
  @Test
  func requestsAccessWhenTrustIsMissing() {
    var requested = false
    let service = AccessibilityPermissionService(
      isTrusted: { false },
      canPostEvents: { true },
      requestAccess: { requested = true },
      openSettings: {}
    )

    #expect(service.requestAccessIfNeeded() == false)
    #expect(requested)
  }

  @Test
  func skipsPromptWhenAlreadyTrusted() {
    var requested = false
    let service = AccessibilityPermissionService(
      isTrusted: { true },
      canPostEvents: { true },
      requestAccess: { requested = true },
      openSettings: {}
    )

    #expect(service.requestAccessIfNeeded())
    #expect(requested == false)
  }

  @Test
  func requestsAccessWhenPostEventAccessIsMissing() {
    var requested = false
    let service = AccessibilityPermissionService(
      isTrusted: { true },
      canPostEvents: { false },
      requestAccess: { requested = true },
      openSettings: {}
    )

    #expect(service.requestAccessIfNeeded() == false)
    #expect(requested)
  }

  @Test
  func hasAccessRequiresTrustAndPostEventAccess() {
    let service = AccessibilityPermissionService(
      isTrusted: { true },
      canPostEvents: { false },
      requestAccess: {},
      openSettings: {}
    )

    #expect(service.hasAccess() == false)
  }
}
