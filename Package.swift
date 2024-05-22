// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HttpFileStorage",
    dependencies: [
        .package(url: "https://github.com/tomieq/swifter.git", .upToNextMajor(from: "1.5.7"))
    ],
    targets: [
        .target(
            name: "HttpFileStorage",
            dependencies: ["Swifter"],
            path: "Sources")
    ]
)
