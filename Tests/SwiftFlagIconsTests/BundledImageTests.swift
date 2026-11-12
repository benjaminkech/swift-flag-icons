import Foundation
import Testing
@testable import CircleFlagArtwork
@testable import FlagIconsCore
@testable import SquareFlagArtwork

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// The codes listed in Swift and the images in each bundle are written by one script, and this
/// checks they agree. The images are only there when the asset catalog was compiled, which Xcode
/// does and `swift build` doesn't: without them there is nothing to check.
@Suite("Bundled images")
struct BundledImageTests {
    private func hasImage(_ code: String, in bundle: Bundle) -> Bool {
        #if canImport(UIKit) && !os(watchOS)
        UIImage(named: code, in: bundle, with: nil) != nil
        #elseif canImport(AppKit)
        bundle.image(forResource: code) != nil
        #else
        true
        #endif
    }

    @Test func everyCircleFlagIsInItsBundle() {
        let bundle = CircleFlagArtwork.resourceBundle
        guard hasImage("ch", in: bundle) else { return }

        #expect(circleFlagCodes.filter { !hasImage($0, in: bundle) }.sorted() == [])
    }

    @Test func everySquareFlagIsInItsBundle() {
        let bundle = SquareFlagArtwork.resourceBundle
        guard hasImage("ch", in: bundle) else { return }

        #expect(squareFlagCodes.filter { !hasImage($0, in: bundle) }.sorted() == [])
    }

    /// A flag isn't one picture in two frames: each shape's styles draw the flags made for it
    @Test func stylesDrawTheArtworkOfTheirShape() {
        #expect(FlagIconStyle.circle.artwork.bundle == CircleFlagArtwork.resourceBundle)
        #expect(FlagIconStyle.square.artwork.bundle == SquareFlagArtwork.resourceBundle)
        #expect(FlagIconStyle.roundedSquare.artwork.bundle == SquareFlagArtwork.resourceBundle)
        #expect(CircleFlagArtwork.resourceBundle != SquareFlagArtwork.resourceBundle)
    }
}
