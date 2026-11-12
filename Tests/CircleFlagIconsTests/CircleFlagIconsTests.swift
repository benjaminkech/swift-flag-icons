import Testing
import SwiftUI
import CircleFlagIcons

/// What an app gets that imports `CircleFlagIcons` alone. That it compiles is half the test: it
/// names nothing of the square artwork, which this target isn't built with.
@Suite("Circle flag icons alone")
struct CircleFlagIconsTests {
    @Test func hasItsOwnArtworkAndStyle() {
        #expect(FlagArtwork.circle.hasFlag(for: "CH"))
        #expect(FlagIconStyle.circle.shape == .circle)
        #expect(!FlagArtwork.circleVersion.isEmpty)
    }

    @MainActor
    @Test func flagNeedsNoStyle() {
        _ = FlagIcon("CH")
        _ = FlagIcon("CH").resizable().flagIconStyle(.circle)
    }
}
