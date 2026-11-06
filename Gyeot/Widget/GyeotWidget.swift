import SwiftUI
import WidgetKit

struct PetEntry: TimelineEntry {
    let date: Date
    let state: CoupleState
}

struct PetProvider: TimelineProvider {
    func placeholder(in context: Context) -> PetEntry {
        PetEntry(date: .now, state: CoupleState())
    }

    func getSnapshot(in context: Context, completion: @escaping (PetEntry) -> Void) {
        completion(PetEntry(date: .now, state: PetStore.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PetEntry>) -> Void) {
        // 받은 행동의 효과(2시간)와 삐짐(24시간)이 시간에 따라 바뀌므로 15분 간격으로 다시 그린다.
        let state = PetStore.load()
        var entries: [PetEntry] = []
        for minutes in stride(from: 0, through: 120, by: 15) {
            let date = Calendar.current.date(byAdding: .minute, value: minutes, to: .now) ?? .now
            entries.append(PetEntry(date: date, state: state))
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct GyeotWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: PetEntry

    private var expression: PetFace {
        entry.state.expression(of: entry.state.partner, now: entry.date)
    }

    var body: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                PetView(expression: expression, tint: .white).padding(4)
            }
        case .accessoryRectangular:
            HStack(spacing: 8) {
                PetView(expression: expression, tint: .white).frame(width: 44, height: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.state.partnerName).font(.headline).widgetAccentable()
                    Text(expression.caption).font(.caption2).lineLimit(2)
                }
                Spacer(minLength: 0)
            }
        default:
            VStack(spacing: 6) {
                PetView(expression: expression)
                Text(expression.caption).font(.caption).multilineTextAlignment(.center).lineLimit(2)
                Text("\(entry.state.daysTogether)일째").font(.caption2).foregroundStyle(.secondary).monospacedDigit()
            }
            .padding(8)
            .containerBackground(for: .widget) { Color(.systemBackground) }
        }
    }
}

struct GyeotWidget: Widget {
    let kind = "GyeotWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PetProvider()) { entry in
            GyeotWidgetView(entry: entry)
        }
        .configurationDisplayName("곁")
        .description("상대의 오늘 기분이 펫 표정으로 보여요.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .systemSmall])
    }
}

@main
struct GyeotWidgetBundle: WidgetBundle {
    var body: some Widget {
        GyeotWidget()
    }
}
