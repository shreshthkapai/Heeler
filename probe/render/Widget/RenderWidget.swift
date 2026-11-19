import ActivityKit
import SwiftUI
import WidgetKit

@main
struct RenderBundle: WidgetBundle {
    var body: some Widget { RenderWidget() }
}

/// Renders the real island from `AgentLiveActivityWidget.swift` with fixture
/// data. A variant reads `<letter>|<blocked>,<done>,<working>|<card statuses>`:
/// an empty letter is one Host, and no card statuses is counts-only.
enum RenderScenario {
    static let names = ["herdr", "arch", "api", "cli", "docs", "web"]
    static let tasks = [
        "Redesign live activity", "Fix sshd forwarding", "Add rate limits", "Bump version",
        "Update changelog", "Build the settings page",
    ]

    static func parse(_ variant: String) -> (AgentActivityPresentation, LiveActivityHostSnapshot) {
        let parts = variant.split(separator: "|", omittingEmptySubsequences: false).map(String.init)
        let letter = parts.first ?? ""
        let numbers = (parts.count > 1 ? parts[1] : "0,0,1").split(separator: ",").compactMap { Int($0) }
        let counts = AgentActivityAttributes.ContentState.Counts(
            working: numbers.count > 2 ? numbers[2] : 0,
            blocked: numbers.first ?? 0,
            done: numbers.count > 1 ? numbers[1] : 0)
        let statuses = parts.count > 2 ? Array(parts[2]) : []
        let agents = statuses.enumerated().map { index, code in
            AgentActivityDetails.AgentDetail(
                paneID: "w1:p\(index)", kind: "claude", workspace: names[index % names.count],
                status: code == "b" ? "blocked" : code == "d" ? "done" : "working", title: nil,
                rows: [
                    [.init(text: names[index % names.count], bold: true)],
                    [.init(text: tasks[index % tasks.count])],
                ])
        }
        let hostName = letter == "MB" ? "MacBook" : letter.isEmpty ? "198.51.100.15" : "Laptop"
        var hosts = [LiveActivityHostSnapshot.Entry(id: "host", name: hostName, label: letter.isEmpty ? nil : letter)]
        if !letter.isEmpty { hosts.append(.init(id: "other", name: "Mac mini", label: "Mm")) }
        let presentation: AgentActivityPresentation = agents.isEmpty
            ? .countsOnly(counts: counts)
            : .detailed(details: .init(hostName: hostName, agents: agents), counts: counts)
        return (presentation, LiveActivityHostSnapshot(v: 1, hosts: hosts))
    }
}

struct RenderWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ProbeAttributes.self) { context in
            Text("Island render \(context.state.variant)").padding()
        } dynamicIsland: { context in
            let scenario = RenderScenario.parse(context.state.variant)
            return AgentActivityIsland.make(
                presentation: scenario.0, hostID: "host", hostSnapshot: scenario.1)
        }
    }
}
