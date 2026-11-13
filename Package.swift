// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "swift-flag-icons",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
        .visionOS(.v1)
    ],
    // Pick one. Each is the same `FlagIcon`, with the artwork of the shapes it names and no other:
    // an app that only shows circles neither builds nor ships the squares.
    products: [
        // Circles and squares; a flag is a circle unless a style says otherwise
        .library(name: "FlagIcons", targets: ["FlagIcons"]),
        // Circles only
        .library(name: "CircleFlagIcons", targets: ["CircleFlagIcons"]),
        // Squares and rounded squares only; a flag is a square unless a style says otherwise
        .library(name: "SquareFlagIcons", targets: ["SquareFlagIcons"])
    ],
    targets: [
        // The view and its styles, without any artwork
        .target(name: "FlagIconsCore"),

        // The flags of one shape and the styles that draw them
        .target(
            name: "CircleFlagArtwork",
            dependencies: ["FlagIconsCore"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "SquareFlagArtwork",
            dependencies: ["FlagIconsCore"],
            resources: [.process("Resources")]
        ),

        // What an app imports: the core, the artwork, and the style a flag has by default
        .target(name: "CircleFlagIcons", dependencies: ["FlagIconsCore", "CircleFlagArtwork"]),
        .target(name: "SquareFlagIcons", dependencies: ["FlagIconsCore", "SquareFlagArtwork"]),
        .target(name: "FlagIcons", dependencies: ["FlagIconsCore", "CircleFlagArtwork", "SquareFlagArtwork"]),

        .testTarget(name: "FlagIconsTests", dependencies: ["FlagIcons", "FlagIconsCore", "CircleFlagArtwork", "SquareFlagArtwork"]),
        .testTarget(name: "CircleFlagIconsTests", dependencies: ["CircleFlagIcons"]),
        .testTarget(name: "SquareFlagIconsTests", dependencies: ["SquareFlagIcons"])
    ]
)
