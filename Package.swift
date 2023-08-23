// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChatKit2",
    platforms: [
       .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ChatKit2",
            targets: ["ChatKit2"]),
    ],
    dependencies: [
        .package(
           url: "https://github.com/AudioKit/AudioKit.git",
           .upToNextMajor(from: "5.0.0")),
        .package(
            url: "https://github.com/vector-im/swift-ogg.git",
            .upToNextMajor(from: "0.0.1"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ChatKit2",
            dependencies: []),
        .testTarget(
            name: "ChatKit2Tests",
            dependencies: ["ChatKit2"]),
    ]
)
