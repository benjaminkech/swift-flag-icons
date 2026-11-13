import SwiftUI

/// The flag of a country or region, as an icon.
///
/// ```swift
/// FlagIcon("CH")
/// FlagIcon(.switzerland)
/// ```
///
/// Its look comes from the flag icon style of its environment, set with
/// ``SwiftUICore/View/flagIconStyle(_:)``. Like an `Image`, it has a size of its own, which follows
/// Dynamic Type, until it is made ``resizable()`` and given a frame:
///
/// ```swift
/// FlagIcon("JP")
///     .resizable()
///     .frame(width: 40, height: 40)
/// ```
///
/// VoiceOver reads the region's name in the user's language. A code the style's artwork has no
/// flag for is drawn as a placeholder; ``FlagArtwork/hasFlag(for:)`` tells beforehand.
public struct FlagIcon: View {
    private let code: String
    private let defaultStyle: FlagIconStyle
    private var isResizable = false

    @Environment(\.flagIconStyle) private var environmentStyle
    @Environment(\.locale) private var locale
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 24

    /// The flag of the region with this code, in the given style unless the environment sets one.
    ///
    /// The modules with artwork add `init(_:)`, which leaves the style out: a circle with
    /// `CircleFlagIcons` and `FlagIcons`, a square with `SquareFlagIcons`. This is the one
    /// to use with artwork of your own.
    ///
    /// - Parameter regionCode: ISO 3166-1 alpha-2, such as "CH", in either case.
    public init(_ regionCode: String, defaultStyle: FlagIconStyle) {
        code = FlagArtwork.normalized(regionCode)
        self.defaultStyle = defaultStyle
    }

    /// Lets the flag take the size it is offered, as `Image.resizable()` does. It stays as wide
    /// as it is high.
    public func resizable() -> FlagIcon {
        var icon = self
        icon.isResizable = true
        return icon
    }

    public var body: some View {
        if isResizable {
            content
                .aspectRatio(1, contentMode: .fit)
        } else {
            content
                .frame(width: size, height: size)
        }
    }

    private var content: some View {
        let style = environmentStyle ?? defaultStyle
        return Group {
            if let image = style.artwork.image(for: code) {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                FlagPlaceholder()
            }
        }
        .clipShape(FlagIconShape(shape: style.shape))
        .accessibilityElement()
        .accessibilityLabel(Text(locale.localizedString(forRegionCode: code.uppercased()) ?? code.uppercased()))
        .accessibilityAddTraits(.isImage)
    }
}

/// What stands in for a flag there is none of
private struct FlagPlaceholder: View {
    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            ZStack {
                Rectangle()
                    .fill(.quaternary)
                Image(systemName: "globe")
                    .resizable()
                    .scaledToFit()
                    .frame(width: side * 0.55, height: side * 0.55)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
