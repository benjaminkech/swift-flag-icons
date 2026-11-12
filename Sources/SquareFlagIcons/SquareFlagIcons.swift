// Flag icons as squares and rounded squares. Importing this module is all an app needs: it brings the view, the
// styles and the artwork along.

@_exported import FlagIconsCore
@_exported import SquareFlagArtwork
import SwiftUI

extension FlagIcon {
    /// The flag of the region with this code: ISO 3166-1 alpha-2, such as "CH", in either case.
    ///
    /// A square unless the environment sets another style.
    public init(_ regionCode: String) {
        self.init(regionCode, defaultStyle: .square)
    }

    /// The flag of a region. A square unless the environment sets another style.
    @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
    public init(_ region: Locale.Region) {
        self.init(region.identifier, defaultStyle: .square)
    }
}

// Every flag, to look through in Xcode's canvas, larger than the asset catalog's own view
// shows them: there they are the 16 points they are declared at; see Tools/import_flags.py.
#Preview("All flags") {
    let styles: [(name: String, style: FlagIconStyle)] = [("Squares", FlagIconStyle.square), ("Rounded squares", FlagIconStyle.roundedSquare)]
    ScrollView {
        ForEach(styles, id: \.name) { entry in
            Text(verbatim: entry.name)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 52))], spacing: 10) {
                ForEach(entry.style.artwork.regionCodes.sorted(), id: \.self) { code in
                    VStack(spacing: 2) {
                        FlagIcon(code)
                            .resizable()
                            .frame(width: 44, height: 44)
                        Text(verbatim: code)
                            .font(.caption2)
                    }
                }
            }
            .flagIconStyle(entry.style)
        }
        .padding()
    }
}
