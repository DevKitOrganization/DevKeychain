// swift-tools-version: 6.4

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("ImmutableWeakCaptures"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
]

let package = Package(
    name: "DevKeychain",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
        .tvOS(.v26),
        .visionOS(.v26),
        .watchOS(.v26),
    ],
    products: [
        .library(
            name: "DevKeychain",
            targets: ["DevKeychain"],
        )
    ],
    dependencies: [
        .package(url: "https://github.com/DevKitOrganization/DevTesting", from: "1.7.0")
    ],
    targets: [
        .target(
            name: "DevKeychain",
            swiftSettings: swiftSettings,
        ),
        .testTarget(
            name: "DevKeychainTests",
            dependencies: [
                "DevKeychain",
                "DevTesting",
            ],
            swiftSettings: swiftSettings,
        ),
    ],
)
