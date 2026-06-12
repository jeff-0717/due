import SwiftUI
import WidgetKit

private let appGroupId = "group.com.example.due"

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
            colorHex: "#2563EB"
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
            title: defaults?.string(forKey: "title") ?? "Due",
            targetDate: defaults?.string(forKey: "targetDate") ?? "Select countdown",
            daysLeft: defaults?.integer(forKey: "daysLeft") ?? 0,
            icon: defaults?.string(forKey: "icon") ?? "D",
            colorHex: defaults?.string(forKey: "color") ?? "#2563EB"
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
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(entry.daysLeft)")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color(hex: entry.colorHex))
                    .minimumScaleFactor(0.7)
                Text("days")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
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
        Scanner(string: sanitized).scanHexInt64(&value)

        let red = Double((value >> 16) & 0xFF) / 255.0
        let green = Double((value >> 8) & 0xFF) / 255.0
        let blue = Double(value & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}

@main
struct DueWidgetBundle: WidgetBundle {
    var body: some Widget {
        DueWidget()
    }
}
