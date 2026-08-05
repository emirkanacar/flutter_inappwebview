// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_inappwebview_forge_ios",
    platforms: [
        .iOS("12.0"),
    ],
    products: [
        .library(name: "flutter-inappwebview-forge-ios", targets: ["flutter_inappwebview_forge_ios"])
    ],
    dependencies: [
      .package(url: "https://github.com/apple/swift-collections.git", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "flutter_inappwebview_forge_ios",
            dependencies: [
                .product(name: "Collections", package: "swift-collections")
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
