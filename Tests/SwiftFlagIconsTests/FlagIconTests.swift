import Foundation
import Testing
import SwiftFlagIcons

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// The artwork of both shapes, through the module that has both
@Suite("Flag artwork")
struct FlagArtworkTests {
    static let sets: [(name: String, artwork: FlagArtwork)] = [("circle", .circle), ("square", .square)]

    @Test func codeIsTakenInEitherCase() {
        #expect(FlagArtwork.circle.hasFlag(for: "CH"))
        #expect(FlagArtwork.circle.hasFlag(for: "ch"))
        #expect(FlagArtwork.circle.hasFlag(for: " Ch "))
    }

    @Test(arguments: [0, 1])
    func whatIsNotARegionHasNoFlag(_ index: Int) {
        let artwork = Self.sets[index].artwork

        #expect(!artwork.hasFlag(for: ""))
        #expect(!artwork.hasFlag(for: "CHE"))
        #expect(!artwork.hasFlag(for: "ZZ"))
        // What the sets also draw and the standard doesn't assign
        for code in ["UN", "UK", "SU", "YU", "AN", "FX", "AC", "XK", "US-CA", "european_union"] {
            #expect(!artwork.hasFlag(for: code))
        }
        // The sets' own flag for an unknown region, which the placeholder stands in for
        #expect(!artwork.hasFlag(for: "XX"))
        #expect(artwork.image(for: "ZZ") == nil)
    }

    @Test(arguments: [0, 1])
    func regionCodesAreUppercase(_ index: Int) {
        let codes = Self.sets[index].artwork.regionCodes
        let notUppercase = codes.filter { $0 != $0.uppercased() || $0.count != 2 }

        #expect(codes.contains("CH"))
        #expect(notUppercase.isEmpty)
    }

    /// Asked off the main thread, as an app may while it prepares its data
    @Test func canBeAskedFromAnyThread() async {
        let hasFlag = await Task.detached { FlagArtwork.square.hasFlag(for: "JP") && !FlagArtwork.circle.regionCodes.isEmpty }.value

        #expect(hasFlag)
    }

    /// Every country a `Locale.Region` can be has a flag in both sets, but for those the system
    /// knows by a code the standard doesn't assign: Ascension, Clipperton, Sark, Diego Garcia,
    /// Ceuta and Melilla, the Canary Islands, Tristan da Cunha and Kosovo
    @Test(arguments: [0, 1])
    func everyRegionTheSystemKnowsHasAFlag(_ index: Int) {
        // Checked inside rather than with `@available` on the test, which crashed the test
        // runner for a test with arguments
        guard #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) else { return }
        let regions = Locale.Region.isoRegions
            .filter { $0.subRegions.isEmpty && $0.identifier.count == 2 }
            .map(\.identifier)
        let missing = Set(regions).subtracting(Self.sets[index].artwork.regionCodes)

        #expect(missing.sorted() == ["AC", "CP", "CQ", "DG", "EA", "IC", "TA", "XK"])
    }

    @Test func stylesHaveTheirShape() {
        #expect(FlagIconStyle.circle.shape == .circle)
        #expect(FlagIconStyle.square.shape == .square)
        #expect(FlagIconStyle.roundedSquare.shape == .roundedSquare(cornerFraction: FlagIconStyle.appIconCornerFraction))
    }

    /// Whichever shape an app shows, it can show the same regions: the 249 of ISO 3166-1 and
    /// the European Union
    @Test func bothShapesHaveTheSameFlags() {
        #expect(FlagArtwork.circle.regionCodes == FlagArtwork.square.regionCodes)
        #expect(FlagArtwork.circle.regionCodes.count == 250)
        #expect(FlagArtwork.circle.hasFlag(for: "EU"))
    }

    @Test func cornerFractionStaysBetweenASquareAndACircle() {
        #expect(FlagIconStyle.roundedSquare(cornerFraction: -1).shape == .roundedSquare(cornerFraction: 0))
        #expect(FlagIconStyle.roundedSquare(cornerFraction: 2).shape == .roundedSquare(cornerFraction: 0.5))
    }

    @Test func artworkOfYourOwnIsNamedWithItsPrefix() {
        let own = FlagArtwork(bundle: .main, namePrefix: "Pixel/", regionCodes: ["ch", "JP"])

        #expect(own.regionCodes == ["CH", "JP"])
        #expect(own.image(for: "jp") != nil)
        #expect(own.image(for: "FR") == nil)
    }
}
