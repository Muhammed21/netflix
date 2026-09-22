// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "DesignTokens",
  platforms: [.iOS(.v16), .macOS(.v13), .tvOS(.v16)],
  products: [
    .library(name: "DesignTokens", targets: ["DesignTokens"]),
  ],
  targets: [
    .target(name: "DesignTokens"),
  ]
)
