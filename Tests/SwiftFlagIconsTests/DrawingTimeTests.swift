import Foundation
import Testing
@testable import CircleFlagArtwork
@testable import SquareFlagArtwork

#if canImport(UIKit) && !os(watchOS)
import UIKit

/// How long it takes to draw the flags, to tell what keeping only the vector costs.
///
/// The flags are declared at 16 points, so at an icon's size each is drawn from its vector rather
/// than shown from a stored bitmap (see `Tools/import_flags.py`). To compare, import them with
/// `--declared-size 40`, which stores a bitmap at that size, run this, and import them again
/// without it:
///
///     TEST_RUNNER_FLAG_TIMING=1 xcodebuild test -scheme swift-flag-icons-Package \
///         -destination 'platform=iOS,name=<your iPhone>' -only-testing:SwiftFlagIconsTests/DrawingTimeTests
///
/// Run it on a device: a simulator draws with the Mac's processor. Skipped unless asked for.
@Suite("Drawing time", .serialized, .enabled(if: DrawingTime.isRequested, "Set FLAG_TIMING=1"))
struct DrawingTimeTests {
    @Test(arguments: [40, 96])
    func drawingEveryCircleFlag(_ points: Int) throws {
        try measure("circle", codes: circleFlagCodes, bundle: CircleFlagArtwork.resourceBundle, points: CGFloat(points))
    }

    @Test(arguments: [40, 96])
    func drawingEverySquareFlag(_ points: Int) throws {
        try measure("square", codes: squareFlagCodes, bundle: SquareFlagArtwork.resourceBundle, points: CGFloat(points))
    }

    /// Draws each flag once into a picture of the given size, as a list does when its rows first
    /// come on screen, then all of them again several times, as when scrolling back over them.
    private func measure(_ name: String, codes: Set<String>, bundle: Bundle, points: CGFloat) throws {
        let codes = codes.sorted()
        try #require(UIImage(named: codes[0], in: bundle, with: nil) != nil, "Needs the asset catalog compiled, so Xcode")

        let format = UIGraphicsImageRendererFormat()
        format.scale = 3
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: points, height: points), format: format)
        let rect = CGRect(x: 0, y: 0, width: points, height: points)
        let clock = ContinuousClock()

        func drawAll() -> Duration {
            clock.measure {
                for code in codes {
                    let image = UIImage(named: code, in: bundle, with: nil)
                    _ = renderer.image { _ in image?.draw(in: rect) }
                }
            }
        }

        let first = drawAll()
        let again = (0..<5).map { _ in drawAll() }.min() ?? first

        func milliseconds(_ duration: Duration) -> Double {
            Double(duration.components.seconds) * 1000 + Double(duration.components.attoseconds) / 1e15
        }
        let line = String(
            format: "Drawing time, %@ at %.0f pt: first %.3f ms a flag, again %.3f ms a flag (%d flags)",
            name, points, milliseconds(first) / Double(codes.count), milliseconds(again) / Double(codes.count), codes.count
        )
        print(line)
        if let folder = DrawingTime.folder {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let file = folder.appendingPathComponent("drawing-time.txt")
            let existing = (try? String(contentsOf: file, encoding: .utf8)) ?? ""
            try (existing + line + "\n").write(to: file, atomically: true, encoding: .utf8)
        }
    }
}
#endif

/// Whether the timing was asked for, apart from the suite so its own condition can ask
enum DrawingTime {
    static var isRequested: Bool {
        ProcessInfo.processInfo.environment["FLAG_TIMING"] == "1"
    }

    /// Where to also write the result, as a test's output is hard to get at from a device or a script
    static var folder: URL? {
        ProcessInfo.processInfo.environment["FLAG_TIMING_FOLDER"].map { URL(fileURLWithPath: $0, isDirectory: true) }
    }
}
