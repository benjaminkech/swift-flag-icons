import SwiftUI

/// How a ``FlagIcon`` looks: the shape it is cut to, and the artwork drawn for that shape.
///
/// Set it for a view and everything in it, as with a button style:
///
/// ```swift
/// List(countries) { country in
///     Label(country.name) { FlagIcon(country.code) }
/// }
/// .flagIconStyle(.roundedSquare)
/// ```
///
/// A flag isn't one picture in two frames here. In a circle its emblems are placed to stay within
/// the circle; in a square they are placed for the square. The styles come with the artwork: the
/// module of a shape has that shape's.
public struct FlagIconStyle: Sendable {
    /// The outline a flag is cut to.
    public enum Shape: Hashable, Sendable {
        case circle
        case square
        /// A square with rounded corners.
        ///
        /// - Parameter cornerFraction: The corners' radius as a share of the side, from 0 for a
        ///   square to 0.5 for a circle. Being a share, it stays in proportion at every size.
        case roundedSquare(cornerFraction: CGFloat)
    }

    /// The outline a flag is cut to.
    public let shape: Shape

    /// The flags that are drawn.
    public let artwork: FlagArtwork

    /// A style of your own: any artwork in any shape.
    public init(shape: Shape, artwork: FlagArtwork) {
        if case .roundedSquare(let cornerFraction) = shape {
            self.shape = .roundedSquare(cornerFraction: min(max(cornerFraction, 0), 0.5))
        } else {
            self.shape = shape
        }
        self.artwork = artwork
    }

    /// Corners a little over a fifth of the side, as an app's icon has
    public static let appIconCornerFraction: CGFloat = 0.225
}

/// The outline a flag icon is cut to
struct FlagIconShape: SwiftUI.Shape {
    let shape: FlagIconStyle.Shape

    func path(in rect: CGRect) -> Path {
        switch shape {
        case .circle:
            Path(ellipseIn: rect)
        case .square:
            Path(rect)
        case .roundedSquare(let cornerFraction):
            Path(roundedRect: rect, cornerRadius: min(rect.width, rect.height) * cornerFraction, style: .continuous)
        }
    }
}

private struct FlagIconStyleKey: EnvironmentKey {
    static let defaultValue: FlagIconStyle? = nil
}

extension EnvironmentValues {
    /// The style set for flag icons, or `nil` for the one they have by default
    var flagIconStyle: FlagIconStyle? {
        get { self[FlagIconStyleKey.self] }
        set { self[FlagIconStyleKey.self] = newValue }
    }
}

extension View {
    /// Sets the style of the flag icons in this view.
    public func flagIconStyle(_ style: FlagIconStyle) -> some View {
        environment(\.flagIconStyle, style)
    }
}
