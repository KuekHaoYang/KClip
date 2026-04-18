import Foundation
import Testing

@Suite("BuildScriptSigningRegressionTests")
struct BuildScriptSigningRegressionTests {
  @Test
  func buildScriptUsesStableSigningAndInstalledAppLocation() throws {
    let sourceURL = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appending(path: "script/build_and_run.sh")

    let source = try String(contentsOf: sourceURL, encoding: .utf8)

    #expect(source.contains("Apple Development"))
    #expect(source.contains("--identifier \"$BUNDLE_ID\""))
    #expect(source.contains("$HOME/Applications"))
    #expect(source.contains("CFBundleIconFile"))
    #expect(source.contains("CFBundleShortVersionString"))
    #expect(source.contains("render_brand.swift"))
  }
}
