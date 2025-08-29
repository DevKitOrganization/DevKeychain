// swift-tools-version: 6.1

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("MemberImportVisibility"),
]

let package = Package(
    name: "DevKeychain",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .tvOS(.v18),
        .visionOS(.v2),
        .watchOS(.v11),
    ],
    products: [
        .library(
            name: "DevKeychain",
            targets: ["DevKeychain"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/DevKitOrganization/DevTesting", from: "1.0.0-beta.10")
    ],
    targets: [
        .target(
            name: "DevKeychain",
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "DevKeychainTests",
            dependencies: [
                "DevKeychain",
                "DevTesting",
            ],
            swiftSettings: swiftSettings
        ),
    ]
)
