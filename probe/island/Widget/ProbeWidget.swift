import ActivityKit
import SwiftUI
import WidgetKit

@main
struct ProbeBundle: WidgetBundle {
    var body: some Widget { ProbeWidget() }
}

private let blocked = Color(red: 0xf3 / 255, green: 0x8b / 255, blue: 0xa8 / 255)
private let done = Color(red: 0xa6 / 255, green: 0xe3 / 255, blue: 0xa1 / 255)
private let working = Color(red: 0xf9 / 255, green: 0xe2 / 255, blue: 0xaf / 255)

private enum Status { case blocked, done, working }

private struct Mark: View {
    let status: Status
    var body: some View {
        switch status {
        case .blocked:
            Image(systemName: "exclamationmark.circle.fill").font(.system(size: 15)).foregroundStyle(blocked)
        case .done:
            Image(systemName: "checkmark.circle.fill").font(.system(size: 15)).foregroundStyle(done)
        case .working:
            ZStack {
                Circle().stroke(working.opacity(0.28), lineWidth: 2.2)
                Circle().trim(from: 0, to: 0.7).stroke(working, style: .init(lineWidth: 2.2, lineCap: .round)).rotationEffect(.degrees(-90))
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
                .foregroundStyle(status == .blocked ? blocked : status == .done ? done : working)
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
            Text("1").font(.system(size: 15.5, weight: .semibold)).foregroundStyle(working)
                .frame(width: 15, alignment: .leading)
        }
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
                Mark(status: .blocked)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("probe-minimal-\(context.state.variant)")
            }
        }
    }
}
