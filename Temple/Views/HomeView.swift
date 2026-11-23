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

/// Last 7 days, newest first: a check on the days you trained with the plan(s) done, an empty circle on rest days. Tap a row to open the day.
struct TrainingWeekCard: View {
    @Query private var logs: [SetLog]
    @Query private var sessions: [WorkoutSession]
    private let days: [Date]

    init() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        days = (0..<7).compactMap { cal.date(byAdding: .day, value: -$0, to: today) }   // today first
        let start = days.last ?? today
        _logs = Query(filter: #Predicate<SetLog> { $0.date >= start })
        _sessions = Query(filter: #Predicate<WorkoutSession> { $0.date >= start }, sort: \.date)
    }

    private func planNames(on d: Date) -> [String] {
        let cal = Calendar.current
        var names: [String] = []
        for s in sessions where cal.isDate(s.date, inSameDayAs: d) {
            let n = (s.planName?.isEmpty == false) ? s.planName! : "Workout"
            if !names.contains(n) { names.append(n) }
        }
        return names
    }

    var body: some View {
        let cal = Calendar.current
        let trained = Set(logs.map { cal.startOfDay(for: $0.date) })
        VStack(alignment: .leading, spacing: 12) {
            Text("Training").font(.system(size: 20, weight: .bold)).foregroundStyle(Color.textPrimary).padding(.bottom, 4)
            ForEach(days, id: \.self) { d in
                let isDone = trained.contains(d)
                let isToday = cal.isDateInToday(d)
                let names = planNames(on: d)
                NavigationLink { DayDetailView(date: d) } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle().fill(isDone ? Color.yolk : Color.clear)
                            Circle().stroke(isDone ? Color.clear : Color.raised, lineWidth: 2)
                            if isDone { Image(systemName: "checkmark").font(.system(size: 14, weight: .bold)).foregroundStyle(Color.yolkInk) }
                        }.frame(width: 32, height: 32)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(isDone ? (names.isEmpty ? "Workout" : names.joined(separator: " · ")) : "Rest")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(isDone ? Color.textPrimary : Color.textSecondary).lineLimit(1)
                            Text(isToday ? "Today" : d.formatted(.dateTime.weekday(.wide).day().month(.abbreviated)))
                                .font(.system(size: 13, weight: isToday ? .semibold : .regular))
                                .foregroundStyle(isToday ? Color.yolk : Color.textSecondary)
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.textSecondary.opacity(0.6))
                    }
                    .padding(.vertical, 4).contentShape(Rectangle())
                }.buttonStyle(.plain)
            }
        }
        .padding(Space.inCard).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.card, in: RoundedRectangle(cornerRadius: Radius.card))
    }
}
