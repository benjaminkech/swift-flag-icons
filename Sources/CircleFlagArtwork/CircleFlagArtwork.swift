import FlagIconsCore
import Foundation

extension FlagArtwork {
    /// The flags drawn for a circle, from circle-flags by HatScripts.
    public static let circle = FlagArtwork(bundle: .module, regionCodes: circleFlagCodes)

    /// The release of circle-flags the flags are from.
    public static let circleVersion = circleFlagsVersion
}

extension FlagIconStyle {
    /// A circle.
    public static let circle = FlagIconStyle(shape: .circle, artwork: .circle)
}

/// The bundle the flags are in, for the tests to look into
enum CircleFlagArtwork {
    static let resourceBundle = Bundle.module
}
