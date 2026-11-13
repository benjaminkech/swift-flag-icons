import Foundation
import SwiftUI
import Testing
import FlagIcons

/// Draws every flag of a style into one picture, to look through after the artwork was updated:
/// an asset catalog doesn't draw everything an SVG can say, and nothing but eyes tells.
///
///     FLAG_CONTACT_SHEETS=/tmp/flags xcodebuild test -scheme swift-flag-icons-Package -destination 'platform=macOS'
///
/// Skipped unless the folder to write to is given. Needs the asset catalog compiled, so Xcode.
@Suite("Contact sheets", .enabled(if: ContactSheets.folder != nil, "Set FLAG_CONTACT_SHEETS to a folder"))
@MainActor
struct ContactSheetTests {

    @Test(arguments: ["circle", "square", "roundedSquare", "circleArtworkUncut"])
    func drawsEveryFlag(_ name: String) throws {
        guard #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) else { return }
        let style: FlagIconStyle = switch name {
        case "circle": .circle
        case "square": .square
        // The circles' artwork as it is in the catalog, without the view cutting it
        case "circleArtworkUncut": FlagIconStyle(shape: .square, artwork: .circle)
        default: .roundedSquare
        }
        let codes = style.artwork.regionCodes.sorted()
        let columns = Array(repeating: GridItem(.fixed(56), spacing: 8), count: 16)

        let sheet = LazyVGrid(columns: columns, spacing: 8) {
            ForEach(codes, id: \.self) { code in
                VStack(spacing: 2) {
                    FlagIcon(code)
                        .resizable()
                        .frame(width: 44, height: 44)
                    Text(verbatim: code)
                        .font(.system(size: 9))
                }
            }
        }
        .flagIconStyle(style)
        .padding(12)
        .background(Color.white)
        .environment(\.colorScheme, .light)

        let renderer = ImageRenderer(content: sheet)
        renderer.scale = 2
        let folder = try #require(ContactSheets.folder)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let url = folder.appendingPathComponent("\(name).png")

        #if canImport(AppKit)
        let image = try #require(renderer.nsImage)
        let bitmap = try #require(image.tiffRepresentation.flatMap(NSBitmapImageRep.init(data:)))
        try #require(bitmap.representation(using: .png, properties: [:])).write(to: url)
        #elseif canImport(UIKit)
        try #require(renderer.uiImage?.pngData()).write(to: url)
        #endif
    }
}

/// Where the contact sheets go, apart from the suite so its own condition can ask
enum ContactSheets {
    static var folder: URL? {
        ProcessInfo.processInfo.environment["FLAG_CONTACT_SHEETS"].map { URL(fileURLWithPath: $0, isDirectory: true) }
    }
}
