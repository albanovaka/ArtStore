// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "ArtStore",
    products: [
        .library(
            name: "ArtStore",
            targets: ["ArtStore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/stripe/stripe-ios.git", from: "21.0.0")
    ],
    targets: [
        .target(
            name: "ArtStore"),
        .testTarget(
            name: "ArtStoreTests")
    ]
)

