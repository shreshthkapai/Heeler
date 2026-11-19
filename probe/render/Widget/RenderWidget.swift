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
    static let tasks = [
        "herdr": "Redesign live activity", "arch": "Fix sshd forwarding", "api": "Add rate limits",
        "cli": "Bump version", "docs": "Update changelog", "web": "Build the settings page",
        "tests": "Run the full suite", "main": "Calibrate camera rig",
    ]
    static let defaultNames = ["herdr", "arch", "api", "cli", "docs", "web"]

    static func parse(_ variant: String) -> (AgentActivityPresentation, LiveActivityHostSnapshot) {
        let parts = variant.split(separator: "|", omittingEmptySubsequences: false).map(String.init)
        let letter = parts.first ?? ""
        let numbers = (parts.count > 1 ? parts[1] : "0,0,1").split(separator: ",").compactMap { Int($0) }
        let counts = AgentActivityAttributes.ContentState.Counts(
            working: numbers.count > 2 ? numbers[2] : 0,
            blocked: numbers.first ?? 0,
            done: numbers.count > 1 ? numbers[1] : 0)
        let statuses = parts.count > 2 ? Array(parts[2]) : []
        let names = parts.count > 3 ? parts[3].split(separator: ",").map(String.init) : defaultNames
        let agents = statuses.enumerated().map { index, code in
            let name = names[index % names.count]
            return AgentActivityDetails.AgentDetail(
                paneID: "w1:p\(index)", kind: "claude", workspace: name,
                status: code == "b" ? "blocked" : code == "d" ? "done" : "working", title: nil,
                rows: [[.init(text: name, bold: true)], [.init(text: tasks[name] ?? name)]])
        }
        let hostName = switch letter {
        case "MB": "MacBook"
        case "M", "Mm": "Mac mini"
        case "": "198.51.100.15"
        default: "Laptop"
        }
        var hosts = [LiveActivityHostSnapshot.Entry(id: "host", name: hostName, label: letter.isEmpty ? nil : letter)]
        if !letter.isEmpty { hosts.append(.init(id: "other", name: "Workstation", label: "W")) }
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
