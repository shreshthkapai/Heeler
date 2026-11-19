import ActivityKit
import SwiftUI
import WidgetKit

@main
struct ProbeBundle: WidgetBundle {
    var body: some Widget { ProbeWidget() }
}

private let heelerBlocked = Color(red: 0xf3 / 255, green: 0x8b / 255, blue: 0xa8 / 255)
private let heelerDone = Color(red: 0xa6 / 255, green: 0xe3 / 255, blue: 0xa1 / 255)
private let heelerWorking = Color(red: 0xf9 / 255, green: 0xe2 / 255, blue: 0xaf / 255)

private enum Status { case blocked, done, working }

private struct Mark: View {
    let status: Status
    var body: some View {
        switch status {
        case .blocked:
            Image(systemName: "exclamationmark.circle.fill").font(.system(size: 15)).foregroundStyle(heelerBlocked)
        case .done:
            Image(systemName: "checkmark.circle.fill").font(.system(size: 15)).foregroundStyle(heelerDone)
        case .working:
            ZStack {
                Circle().stroke(heelerWorking.opacity(0.28), lineWidth: 2.2)
                Circle().trim(from: 0, to: 0.7).stroke(heelerWorking, style: .init(lineWidth: 2.2, lineCap: .round)).rotationEffect(.degrees(-90))
            }
            .frame(width: 12.6, height: 12.6)
            .frame(width: 15, height: 15)
        }
    }
}

private struct Pair: View {
    let status: Status
    let count: Int
    var body: some View {
        HStack(spacing: 2.5) {
            Mark(status: status)
            Text("\(count)").font(.system(size: 15.5, weight: .semibold)).monospacedDigit()
                .foregroundStyle(status == .blocked ? heelerBlocked : status == .done ? heelerDone : heelerWorking)
        }
    }
}

private func bar(_ color: Color, _ width: CGFloat) -> some View {
    RoundedRectangle(cornerRadius: 3).fill(color).frame(width: width, height: 14)
}

private struct Leading: View {
    let variant: String
    var body: some View {
        switch variant {
        case "nofix": bar(.red, 54)
        case "equal-inward": bar(.red, 54).frame(width: 54, alignment: .trailing)
        case "design-3":
            HStack(spacing: 4.5) { Pair(status: .blocked, count: 1); Pair(status: .done, count: 1) }
                .frame(width: 57, alignment: .trailing)
        case "design-2": Pair(status: .blocked, count: 1).frame(width: 27, alignment: .trailing)
        case "letter-2":
            HStack(spacing: 6) { Pair(status: .blocked, count: 1); Pair(status: .working, count: 4) }
                .frame(width: 57, alignment: .trailing)
        case "other": Text("OT").font(.system(size: 15, weight: .semibold)).foregroundStyle(.orange)
        default: Mark(status: .working).frame(width: 15, alignment: .trailing)
        }
    }
}

private struct Trailing: View {
    let variant: String
    var body: some View {
        switch variant {
        case "nofix": bar(.blue, 13)
        case "equal-inward": bar(.blue, 13).frame(width: 54, alignment: .leading)
        case "design-3": Pair(status: .working, count: 1).frame(width: 57, alignment: .leading)
        case "design-2": Pair(status: .working, count: 4).frame(width: 27, alignment: .leading)
        case "letter-2":
            Text("L").font(.system(size: 15, weight: .semibold)).foregroundStyle(.gray)
                .frame(width: 57, alignment: .leading)
        case "other": Text("99").font(.system(size: 15, weight: .semibold)).foregroundStyle(.orange)
        default:
            Text("1").font(.system(size: 15.5, weight: .semibold)).foregroundStyle(heelerWorking)
                .frame(width: 15, alignment: .leading)
        }
    }
}

private let ink = Color(red: 0x1e / 255, green: 0x1e / 255, blue: 0x2e / 255)

/// Minimal B, transcribed from minB() and glyph() in the approved Island Scenarios page (r = 10).
private struct MinimalB: View {
    let blocked: Int
    let done: Int
    let working: Int

    private var present: [(Status, Int)] {
        [(Status.blocked, blocked), (.done, done), (.working, working)].filter { $0.1 > 0 }
    }

    private func color(_ status: Status) -> Color {
        switch status {
        case .blocked: return heelerBlocked
        case .done: return heelerDone
        case .working: return heelerWorking
        }
    }

    var body: some View {
        ZStack {
            if let first = present.first {
                topMark(first.0, first.1).offset(y: -2)
                HStack(spacing: 2.2) {
                    ForEach(Array(present.dropFirst().enumerated()), id: \.offset) { _, item in
                        Circle().fill(color(item.0)).frame(width: 4.8, height: 4.8)
                    }
                }
                .offset(y: 12.5)
            }
        }
        .frame(width: 20, height: 36)
    }

    @ViewBuilder
    private func topMark(_ status: Status, _ count: Int) -> some View {
        let twoDigits = count >= 10
        if status == .working {
            ZStack {
                Circle().stroke(heelerWorking.opacity(0.28), lineWidth: 2.9)
                Circle().trim(from: 0, to: 0.7)
                    .stroke(heelerWorking, style: StrokeStyle(lineWidth: 2.9, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(count)").font(.system(size: twoDigits ? 10 : 11.5, weight: .bold)).foregroundStyle(heelerWorking)
            }
            .frame(width: 16.8, height: 16.8)
            .frame(width: 20, height: 20)
        } else {
            ZStack {
                Circle().fill(color(status))
                Text("\(count)").font(.system(size: twoDigits ? 10.5 : 12, weight: .bold)).foregroundStyle(ink)
            }
            .frame(width: 20, height: 20)
        }
    }
}

private func minimalCounts(_ variant: String) -> (Int, Int, Int)? {
    switch variant {
    case "min-132": return (1, 3, 2)
    case "min-005": return (0, 0, 5)
    case "min-100": return (1, 0, 0)
    default: return nil
    }
}

struct ProbeWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ProbeAttributes.self) { context in
            Text("Island probe \(context.state.variant)").padding()
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) { Text(context.state.variant) }
            } compactLeading: {
                Leading(variant: context.state.variant)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("probe-lead-\(context.state.variant)")
            } compactTrailing: {
                Trailing(variant: context.state.variant)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("probe-trail-\(context.state.variant)")
            } minimal: {
                Group {
                    if let counts = minimalCounts(context.state.variant) {
                        MinimalB(blocked: counts.0, done: counts.1, working: counts.2)
                    } else if context.state.variant == "other" {
                        Text("OT").font(.system(size: 13, weight: .bold)).foregroundStyle(.orange)
                    } else {
                        Mark(status: .blocked)
                    }
                }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("probe-minimal-\(context.state.variant)")
            }
        }
    }
}
