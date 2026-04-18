import Foundation
import Testing

@Suite("ReleasePackagingRegressionTests")
struct ReleasePackagingRegressionTests {
  @Test
  func releaseScriptStripsMacMetadataBeforeCreatingZip() throws {
    let sourceURL = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appending(path: "script/make_release.sh")

    let source = try String(contentsOf: sourceURL, encoding: .utf8)

    #expect(source.contains("xattr -cr"))
    #expect(source.contains("DITTONORSRC=1"))
    #expect(source.contains("--norsrc"))
    #expect(source.contains("--noextattr"))
    #expect(source.contains("--noqtn"))
  }
}
