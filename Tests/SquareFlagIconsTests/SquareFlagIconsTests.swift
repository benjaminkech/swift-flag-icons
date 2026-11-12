import Testing
import SwiftUI
import SquareFlagIcons

/// What an app gets that imports `SquareFlagIcons` alone. That it compiles is half the test: it
/// names nothing of the circle artwork, which this target isn't built with.
@Suite("Square flag icons alone")
struct SquareFlagIconsTests {
    @Test func hasItsOwnArtworkAndStyle() {
        #expect(FlagArtwork.square.hasFlag(for: "CH"))
        #expect(FlagIconStyle.square.shape == .square)
        #expect(!FlagArtwork.squareVersion.isEmpty)
    }

    @MainActor
    @Test func flagNeedsNoStyle() {
        _ = FlagIcon("CH")
        _ = FlagIcon("CH").resizable().flagIconStyle(.square)
    }
}
