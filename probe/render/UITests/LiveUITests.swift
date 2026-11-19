import XCTest

/// Runs the cases in $LIVE_CASES (one "<view> <variant>" per line) and writes
/// each screenshot to $LIVE_OUT/<view>-<variant>.png on the Mac.
final class LiveUITests: XCTestCase {
    private let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    private let render = "dev.example.islandrender"
    private let other = XCUIApplication(bundleIdentifier: "dev.example.islandrender.other")

    private func launch(_ bundle: String, _ variant: String) {
        let app = XCUIApplication(bundleIdentifier: bundle)
        app.launchArguments = ["-variant", variant]
        app.launch()
        sleep(3)
    }

    private func shoot(_ name: String, into dir: URL) {
        let file = dir.appendingPathComponent(name.replacingOccurrences(of: "|", with: "_") + ".png")
        try? XCUIScreen.main.screenshot().pngRepresentation.write(to: file)
        print("LIVE-SHOT \(file.path)")
    }

    func testCases() throws {
        let env = ProcessInfo.processInfo.environment
        let cases = try String(contentsOfFile: try XCTUnwrap(env["LIVE_CASES"]), encoding: .utf8)
            .split(separator: "\n").map { $0.split(separator: " ", maxSplits: 1).map(String.init) }
        let dir = URL(fileURLWithPath: try XCTUnwrap(env["LIVE_OUT"]))
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        var otherState = ""
        for entry in cases where entry.count == 2 {
            let (view, variant) = (entry[0], entry[1])
            let wantOther = view == "minimal" ? "other" : "none"
            if wantOther != otherState {
                launch("dev.example.islandrender.other", wantOther)
                otherState = wantOther
            }
            launch(render, variant)
            switch view {
            case "landscape":
                other.activate()
                sleep(1)
                XCUIDevice.shared.orientation = .landscapeLeft
                sleep(3)
                shoot("\(view)-\(variant)", into: dir)
                XCUIDevice.shared.orientation = .portrait
                sleep(1)
            case "expanded":
                XCUIDevice.shared.press(.home)
                sleep(2)
                springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0))
                    .withOffset(CGVector(dx: 0, dy: 30))
                    .press(forDuration: 1.2)
                sleep(1)
                shoot("\(view)-\(variant)", into: dir)
                XCUIDevice.shared.press(.home)
            default:
                XCUIDevice.shared.press(.home)
                sleep(3)
                shoot("\(view)-\(variant)", into: dir)
            }
        }
    }
}
