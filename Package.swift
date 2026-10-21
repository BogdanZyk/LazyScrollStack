// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LazyScrollStack",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "LazyScrollStack",
            targets: ["LazyScrollStack"]
        )
    ],
    targets: [
        .target(
            name: "LazyScrollStack",
            swiftSettings: [
                .defaultIsolation(MainActor.self),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
