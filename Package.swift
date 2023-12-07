// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
  name: "swift-sql",
  platforms: [
    .macOS(.v14),
  ],
  products: [
    .library(
      name: "SwiftSQL",
      targets: ["SwiftSQL"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-syntax.git", .upToNextMajor(from: "509.0.2")),
    .package(url: "https://github.com/pointfreeco/swift-macro-testing", .upToNextMajor(from: "0.2.2")),
  ],
  targets: [
    .target(
      name: "SwiftSQL",
      dependencies: [
        .target(name: "SQLModelMacro"),
      ]
    ),
    .macro(
      name: "SQLModelMacro",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
      ]
    ),
    .testTarget(
      name: "SwiftSQLTests",
      dependencies: [
        .target(name: "SwiftSQL"),
        .product(name: "MacroTesting", package: "swift-macro-testing"),
      ]
    ),
  ]
)
