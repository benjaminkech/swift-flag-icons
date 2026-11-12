import FlagIconsCore
import Foundation

extension FlagArtwork {
    /// The flags drawn for a square, from square-flags by Ben Darlow.
    public static let square = FlagArtwork(bundle: .module, regionCodes: squareFlagCodes)

    /// The release of square-flags the flags are from.
    public static let squareVersion = squareFlagsVersion
}

extension FlagIconStyle {
    /// A square.
    public static let square = FlagIconStyle(shape: .square, artwork: .square)

    /// A square with rounded corners, as an app's icon has.
    public static let roundedSquare = roundedSquare(cornerFraction: appIconCornerFraction)

    /// A square with rounded corners of your choosing.
    ///
    /// - Parameter cornerFraction: The corners' radius as a share of the side, from 0 for a
    ///   square to 0.5 for a circle.
    public static func roundedSquare(cornerFraction: CGFloat) -> FlagIconStyle {
        FlagIconStyle(shape: .roundedSquare(cornerFraction: cornerFraction), artwork: .square)
    }
}

/// The bundle the flags are in, for the tests to look into
enum SquareFlagArtwork {
    static let resourceBundle = Bundle.module
}
