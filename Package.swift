// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KClip",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .executable(
            name: "KClip",
            targets: ["KClip"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "KClip"
        ),
        .testTarget(
            name: "KClipTests",
            dependencies: ["KClip"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
