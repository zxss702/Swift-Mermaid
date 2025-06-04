// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftMermaid",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftMermaid",
            targets: ["SwiftMermaid"]),
        .executable(
            name: "MermaidDemo",
            targets: ["MermaidDemo"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftMermaid"),
        .executableTarget(
            name: "MermaidDemo",
            dependencies: ["SwiftMermaid"]
        ),
        .testTarget(
            name: "SwiftMermaidTests",
            dependencies: ["SwiftMermaid"]),
    ]
)