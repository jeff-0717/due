import SwiftUI
import WidgetKit

private let appGroupId = "group.com.example.due"
private let defaultColorHex = "#2563EB"

private enum WidgetKeys {
    static let title = "title"
    static let targetDate = "targetDate"
    static let daysLeft = "daysLeft"
    static let icon = "icon"
    static let color = "color"
}

struct DueEntry: TimelineEntry {
    let date: Date
    let title: String
    let targetDate: String
    let daysLeft: Int
    let icon: String
    let colorHex: String
}

struct DueProvider: TimelineProvider {
    func placeholder(in context: Context) -> DueEntry {
        DueEntry(
            date: Date(),
            title: "Due",
            targetDate: "Select countdown",
            daysLeft: 0,
            icon: "D",
            colorHex: defaultColorHex
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (DueEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DueEntry>) -> Void) {
        let entry = loadEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func loadEntry() -> DueEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        return DueEntry(
            date: Date(),
            title: defaults?.string(forKey: WidgetKeys.title) ?? "Due",
            targetDate: defaults?.string(forKey: WidgetKeys.targetDate) ?? "Select countdown",
            daysLeft: defaults?.integer(forKey: WidgetKeys.daysLeft) ?? 0,
            icon: defaults?.string(forKey: WidgetKeys.icon) ?? "D",
            colorHex: defaults?.string(forKey: WidgetKeys.color) ?? defaultColorHex
        )
    }
}

struct DueWidgetView: View {
    var entry: DueProvider.Entry

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: entry.colorHex))
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 6) {
                Text(entry.icon)
                    .font(.system(size: 18))
                Text(entry.title)
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(1)
                Text(entry.targetDate)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(entry.daysLeft)")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(Color(hex: entry.colorHex))
                    .minimumScaleFactor(0.7)
                Text("days")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .widgetHostBackground()
    }
}

struct DueWidget: Widget {
    let kind = "DueWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DueProvider()) { entry in
            DueWidgetView(entry: entry)
        }
        .configurationDisplayName("Due Countdown")
        .description("Shows the selected countdown on the Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

extension Color {
    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var value: UInt64 = 0
        guard Scanner(string: sanitized).scanHexInt64(&value), sanitized.count == 6 else {
            self.init(hex: defaultColorHex)
            return
        }

        let red = Double((value >> 16) & 0xFF) / 255.0
        let green = Double((value >> 8) & 0xFF) / 255.0
        let blue = Double(value & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}

extension View {
    @ViewBuilder
    func widgetHostBackground() -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            self.containerBackground(.fill.tertiary, for: .widget)
        } else {
            self.background(Color(.systemBackground))
        }
    }
}

@main
struct DueWidgetBundle: WidgetBundle {
    var body: some Widget {
        DueWidget()
    }
}
