import SwiftUI

/// A set of flags in an asset catalog, one image for each region, named by its lowercase code.
///
/// The package's own sets are `circle` and `square`, each in the module of its shape. Make one to
/// draw ``FlagIcon`` with flags of your own:
///
/// ```swift
/// let pixelFlags = FlagArtwork(bundle: .main, namePrefix: "PixelFlags/", regionCodes: ["CH", "JP"])
/// ```
public struct FlagArtwork: Sendable {
    let bundle: Bundle
    private let namePrefix: String
    private let codes: Set<String>

    /// - Parameters:
    ///   - bundle: The bundle whose asset catalog has the images.
    ///   - namePrefix: What comes before the code in an image's name, such as a catalog's folder.
    ///   - regionCodes: The codes there is an image for, in either case.
    public init(bundle: Bundle, namePrefix: String = "", regionCodes: Set<String>) {
        self.bundle = bundle
        self.namePrefix = namePrefix
        codes = Set(regionCodes.map(Self.normalized))
    }

    /// The codes there is a flag for, in uppercase.
    public var regionCodes: Set<String> {
        Set(codes.map { $0.uppercased() })
    }

    /// Whether there is a flag for a region's code, in either case.
    public func hasFlag(for regionCode: String) -> Bool {
        codes.contains(Self.normalized(regionCode))
    }

    /// The flag of a region, or `nil` when the set has none.
    public func image(for regionCode: String) -> Image? {
        let code = Self.normalized(regionCode)
        guard codes.contains(code) else { return nil }
        return Image(namePrefix + code, bundle: bundle)
    }

    /// A region's code as the images are named by it: lowercase, without spaces around it
    static func normalized(_ regionCode: String) -> String {
        regionCode.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
