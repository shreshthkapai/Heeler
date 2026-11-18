import ActivityKit
import SwiftUI

@main
struct ProbeApp: App {
    var body: some Scene {
        WindowGroup {
            Text(status).task { await start() }
        }
    }

    @State private var status = "starting"

    private func start() async {
        let args = ProcessInfo.processInfo.arguments
        let variant = args.firstIndex(of: "-variant").map { args[$0 + 1] } ?? "nofix"
        for activity in Activity<ProbeAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        do {
            _ = try Activity.request(
                attributes: ProbeAttributes(),
                content: .init(state: .init(variant: variant), staleDate: nil)
            )
            status = "started \(variant)"
        } catch {
            status = "failed \(error)"
        }
        print("PROBE \(status) enabled=\(ActivityAuthorizationInfo().areActivitiesEnabled)")
    }
}
