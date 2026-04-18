// swift-tools-version: 6.1
import PackageDescription

let package = Package(
  name: "KClip",
  platforms: [.macOS(.v15)],
  products: [
    .executable(name: "KClip", targets: ["KClip"]),
  ],
  targets: [
    .executableTarget(
      name: "KClip",
      linkerSettings: [
        .linkedFramework("AppKit"),
        .linkedFramework("SwiftUI"),
        .linkedFramework("WebKit"),
        .linkedFramework("Quartz"),
      ]
    ),
    .testTarget(
      name: "KClipTests",
      dependencies: ["KClip"]
    ),
  ]
)
