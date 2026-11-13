# Swift Flag Icons

[![Swift versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbenjaminkech%2Fswift-flag-icons%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/benjaminkech/swift-flag-icons)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbenjaminkech%2Fswift-flag-icons%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/benjaminkech/swift-flag-icons)

Country and region flags for SwiftUI, as vector icons in a circle, a square or a rounded square.

```swift
import SwiftFlagIcons

FlagIcon("CH")
```

- **Drawn for their shape.** A flag in a circle isn't a rectangle with its corners cut off: its
  emblems are placed to sit inside the circle. In a square they are placed for the square.
- **Vector.** Sharp at any size, and small: about half a megabyte for a shape on a device.
- **Modular.** Showing only circles? Then the squares are neither built nor shipped.
- **SwiftUI's way.** One view, styled through the environment like a button, sized like an image.
- **All Apple platforms.** iOS 15, macOS 12, tvOS 15, watchOS 8, visionOS 1, and Mac Catalyst.
- **Nothing else.** No dependencies, no loading, no caching: the flags are in an asset catalog.

## Installation

In Xcode, choose File › Add Package Dependencies and enter the repository's URL. Or in
`Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/benjaminkech/swift-flag-icons.git", from: "1.0.0")
]
```

Then add one of its three libraries to your target. They are the same `FlagIcon` with different
artwork, so pick by the shapes you show:

| Library | Shapes | A flag by default |
|---|---|---|
| `CircleFlagIcons` | circle | a circle |
| `SquareFlagIcons` | square, rounded square | a square |
| `SwiftFlagIcons` | all of them | a circle |

Import the one you added, and nothing else:

```swift
import CircleFlagIcons
```

## Usage

A flag by its ISO 3166-1 alpha-2 code, in either case, or by a `Locale.Region`:

```swift
FlagIcon("JP")
FlagIcon(.japan)
```

### Style

Set the style on a flag, or on any view around it, and it applies to every flag inside, as
`buttonStyle(_:)` does to buttons:

```swift
List(countries) { country in
    Label {
        Text(country.name)
    } icon: {
        FlagIcon(country.code)
    }
}
.flagIconStyle(.roundedSquare)
```

| Style | | Comes with |
|---|---|---|
| `.circle` | | `CircleFlagIcons`, `SwiftFlagIcons` |
| `.square` | | `SquareFlagIcons`, `SwiftFlagIcons` |
| `.roundedSquare` | Corners like an app icon's | `SquareFlagIcons`, `SwiftFlagIcons` |
| `.roundedSquare(cornerFraction:)` | Corners of your choosing, as a share of the side | `SquareFlagIcons`, `SwiftFlagIcons` |

### Size

Like an `Image`, a flag has a size of its own: 24 points, growing and shrinking with Dynamic Type.
Make it resizable to give it another:

```swift
FlagIcon("BR")
    .resizable()
    .frame(width: 40, height: 40)
```

### Regions without a flag

A code there is no flag for is drawn as a placeholder, a globe. To handle it yourself:

```swift
if FlagArtwork.circle.hasFlag(for: code) {
    FlagIcon(code)
} else {
    Text(code)
}
```

`FlagArtwork.circle.regionCodes` lists the codes there is a flag for, and likewise for `.square`.
Both have the same 250: the 249 codes of ISO 3166-1 alpha-2, and `EU` for the European Union.

### Flags of your own

A style is a shape and a set of flags, and neither has to be the package's. With your flags in an
asset catalog, named by their lowercase codes:

```swift
let pixelFlags = FlagArtwork(bundle: .main, namePrefix: "PixelFlags/", regionCodes: ["CH", "JP"])

FlagIcon("CH")
    .flagIconStyle(FlagIconStyle(shape: .square, artwork: pixelFlags))
```

### Widgets

Flags work in widgets. Add the library to the widget extension's target as well as the app's, as
each brings its own copy of the artwork.

### Accessibility

VoiceOver reads a flag as the region's name in the user's language. Next to the name in text, hide
it with `.accessibilityHidden(true)`, or use a `Label`, which does so by itself.

## Library size

What a library adds to an app, as delivered to one device:

| Library | Artwork | With its code, about |
|---|---|---|
| `CircleFlagIcons` | 542 KB | 0.7 MB |
| `SquareFlagIcons` | 482 KB | 0.6 MB |
| `SwiftFlagIcons` | 1.02 MB | 1.2 MB |

The artwork is each set's compiled asset catalog, measured for an iPhone. The code is roughly
150 KB before the linker strips what an app doesn't use, the same whichever library is chosen.

It is this small because a flag is kept as its vector and a picture of only 16 points beside it,
where an asset catalog would otherwise store one in pixels at the full size the artwork declares:
4.8 MB for a set. `Tools/import_flags.py` says how. Larger than 16 points, a flag is drawn from the
vector, which was checked to be sharp on iOS, macOS and watchOS and in a widget.

## The artwork

The flags are drawn by others, and this package only brings them to SwiftUI:

- Circles: [circle-flags](https://github.com/HatScripts/circle-flags) by HatScripts, release 2.8.0
- Squares: [square-flags](https://github.com/kapowaz/square-flags) by Ben Darlow, release 1.5.3,
  itself a rework of circle-flags for the square

Both are under the MIT license; see [Licenses](Licenses). Only the flags of ISO 3166-1 alpha-2 and
the European Union's are included, not the sets' flags of states, languages, organizations and
codes outside the standard.

To update the artwork, unpack a new release of either and run:

```bash
python3 Tools/import_flags.py --circle <folder> --circle-version <version> --square <folder> --square-version <version>
```

The script explains what it changes in each file and why. Then look through every flag, as an
asset catalog doesn't draw everything an SVG can say:

```bash
TEST_RUNNER_FLAG_CONTACT_SHEETS=/tmp/flags xcodebuild test -scheme swift-flag-icons-Package -destination 'platform=macOS'
```

## Tests

`swift test` runs the tests that need no images. The ones that look into the asset catalog need
it compiled, which only Xcode does:

```bash
xcodebuild test -scheme swift-flag-icons-Package -destination 'platform=macOS'
```

## License

MIT, see [LICENSE](LICENSE). The artwork has its own notices, as above.
