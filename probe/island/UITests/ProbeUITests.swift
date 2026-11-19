import XCTest

final class ProbeUITests: XCTestCase {
    private let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    override func setUp() {
        continueAfterFailure = true
    }

    private func start(_ bundle: String, _ variant: String) {
        let app = XCUIApplication(bundleIdentifier: bundle)
        app.launchArguments = ["-variant", variant]
        app.launch()
        sleep(5)
    }

    private func record(_ name: String) {
        sleep(4)
        let tree = springboard.debugDescription
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = "\(name)-screen"
        shot.lifetime = .keepAlways
        add(shot)
        let text = XCTAttachment(string: tree)
        text.name = "\(name)-tree"
        text.lifetime = .keepAlways
        add(text)
        print("PROBE-BEGIN \(name)\n\(tree)\nPROBE-END \(name)")
    }

    func test1Compact() {
        for variant in ["nofix", "equal-inward", "design-3", "design-2", "design-1", "letter-2"] {
            start("dev.example.islandprobe", variant)
            XCUIDevice.shared.press(.home)
            record("compact-\(variant)")
        }
    }

    func test2TwoActivities() {
        for variant in ["min-132", "min-005", "min-100"] {
            start("dev.example.islandprobe", variant)
            start("dev.example.islandprobe.other", "other")
            XCUIDevice.shared.press(.home)
            record("two-activities-\(variant)")
        }
    }

    func test3Landscape() {
        start("dev.example.islandprobe", "design-3")
        start("dev.example.islandprobe.other", "none")
        XCUIDevice.shared.orientation = .landscapeLeft
        record("landscape")
        XCUIDevice.shared.orientation = .portrait
    }
}
