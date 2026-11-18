import ActivityKit

struct ProbeAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var variant: String
    }
}
