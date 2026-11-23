import SwiftUI
import SwiftData

/// Overview of the last 7 days: training checks and nutrition bars.
struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    TrainingWeekCard()
                    StepsCard()
                    WeeklyGoalsCard()
                }.padding(Space.margin).foregroundStyle(Color.textPrimary)
            }
            .contentMargins(.bottom, Space.tabBarClearance, for: .scrollContent)
            .background(Color.bg)
            .navigationTitle("Home")
        }
    }
}

/// Last 7 days (ending today): a check on the days you trained, an empty circle on the others. Tap a day to open it.
struct TrainingWeekCard: View {
    @Query private var logs: [SetLog]
    private let days: [Date]

    init() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        days = (0..<7).reversed().compactMap { cal.date(byAdding: .day, value: -$0, to: today) }
        let start = days.first ?? today
        _logs = Query(filter: #Predicate<SetLog> { $0.date >= start })
    }
    private var trained: Set<Date> { Set(logs.map { Calendar.current.startOfDay(for: $0.date) }) }

    var body: some View {
        let done = trained
        VStack(alignment: .leading, spacing: 20) {
            Text("Training").font(.system(size: 20, weight: .bold)).foregroundStyle(Color.textPrimary)
            HStack(spacing: 0) {
                ForEach(days, id: \.self) { d in
                    let isDone = done.contains(d)
                    let isToday = Calendar.current.isDateInToday(d)
                    NavigationLink { DayDetailView(date: d) } label: {
                        VStack(spacing: 8) {
                            Text(d.formatted(.dateTime.weekday(.abbreviated))).font(.system(size: 11, weight: isToday ? .bold : .medium))
                                .foregroundStyle(isToday ? Color.yolk : Color.textSecondary).lineLimit(1).minimumScaleFactor(0.7)
                            ZStack {
                                Circle().fill(isDone ? Color.yolk : Color.clear)
                                Circle().stroke(isDone ? Color.clear : Color.raised, lineWidth: 2)
                                if isDone { Image(systemName: "checkmark").font(.system(size: 15, weight: .bold)).foregroundStyle(Color.yolkInk) }
                            }.frame(width: 36, height: 36)
                            Text("\(Calendar.current.component(.day, from: d))").font(.system(size: 11)).foregroundStyle(Color.textSecondary).monospacedDigit()
                        }.frame(maxWidth: .infinity).contentShape(Rectangle())
                    }.buttonStyle(.plain)
                }
            }
        }
        .padding(Space.inCard).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.card, in: RoundedRectangle(cornerRadius: Radius.card))
    }
}
