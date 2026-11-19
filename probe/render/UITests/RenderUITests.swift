import XCTest

final class RenderUITests: XCTestCase {
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

    private func record(_ name: String, settle: UInt32 = 4) {
        sleep(settle)
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = "\(name)-screen"
        shot.lifetime = .keepAlways
        add(shot)
        let tree = XCTAttachment(string: springboard.debugDescription)
        tree.name = "\(name)-tree"
        tree.lifetime = .keepAlways
        add(tree)
    }

    private func slug(_ variant: String) -> String {
        variant.replacingOccurrences(of: "|", with: "_").replacingOccurrences(of: ",", with: "-")
    }

    private let other = XCUIApplication(bundleIdentifier: "dev.example.islandrender.other")

    /// The first activity of a run takes longer to reach the island.
    private func warmUp() {
        start("dev.example.islandrender", "|0,0,1|")
        XCUIDevice.shared.press(.home)
        sleep(6)
    }

    func test1Compact() {
        start("dev.example.islandrender.other", "none")
        warmUp()
        for variant in [
            "|0,0,2|", "|0,3,0|", "|1,0,0|", "|1,2,0|", "|1,0,4|", "|0,2,3|", "|1,1,1|",
            "|1,12,15|", "|10,12,15|", "L|1,0,0|", "L|0,2,3|", "L|1,1,1|", "MB|1,1,1|", "MB|1,12,15|",
        ] {
            start("dev.example.islandrender", variant)
            XCUIDevice.shared.press(.home)
            record("compact-\(slug(variant))")
        }
    }

    func test2Minimal() {
        start("dev.example.islandrender.other", "other")
        warmUp()
        for variant in ["|1,3,2|", "|0,1,2|", "|0,0,5|", "|1,0,0|", "|0,0,12|"] {
            start("dev.example.islandrender", variant)
            XCUIDevice.shared.press(.home)
            record("minimal-\(slug(variant))")
        }
    }

    func test3Landscape() {
        start("dev.example.islandrender.other", "none")
        warmUp()
        for variant in ["L|1,3,2|", "|1,3,2|", "L|0,0,5|", "|1,0,0|", "MB|0,0,12|"] {
            start("dev.example.islandrender", variant)
            // iOS hides an app's own island while it is in front.
            other.activate()
            sleep(2)
            XCUIDevice.shared.orientation = .landscapeLeft
            record("landscape-\(slug(variant))")
            XCUIDevice.shared.orientation = .portrait
            sleep(2)
        }
    }

    func test4Expanded() {
        start("dev.example.islandrender.other", "none")
        warmUp()
        for variant in [
            "L|1,1,1|bdw", "L|0,2,1|ddw", "L|0,0,3|www", "L|1,3,2|bdddw", "L|0,0,5|wwwww",
            "|0,1,1|dw", "L|1,0,2|",
        ] {
            start("dev.example.islandrender", variant)
            XCUIDevice.shared.press(.home)
            sleep(3)
            springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0))
                .withOffset(CGVector(dx: 0, dy: 30))
                .press(forDuration: 1.2)
            record("expanded-\(slug(variant))", settle: 2)
            XCUIDevice.shared.press(.home)
            sleep(1)
        }
    }
}
