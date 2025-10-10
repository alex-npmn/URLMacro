// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
  name: "URLMacro",
  platforms: [
    .iOS(.v15),
    .macOS(.v12),
    .tvOS(.v15),
    .watchOS(.v8)
  ],
  products: [
    .library(
      name: "URLMacro",
      targets: ["URLMacro"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-syntax", exact: "601.0.1"),
  ],
  targets: [
    .target(
      name: "URLMacro",
      dependencies: ["URLMacroPlugin"]
    ),
    .macro(
      name: "URLMacroPlugin",
      dependencies: [
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftDiagnostics", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        .product(name: "SwiftOperators", package: "swift-syntax"),
        .product(name: "SwiftParser", package: "swift-syntax"),
        .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
        .product(name: "SwiftBasicFormat", package: "swift-syntax"),
        .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
        .product(name: "SwiftSyntaxMacroExpansion", package: "swift-syntax")
      ]
    ),
    .testTarget(
      name: "URLTests",
      dependencies: [
        "URLMacro",
        // host-only diagnostics helpers are conditionally imported in tests
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax", condition: .when(platforms: [.macOS])),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax", condition: .when(platforms: [.macOS]))
      ]
    ),
  ]
)
