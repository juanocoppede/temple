import SwiftUI
import SwiftData

struct CalendarView: View {
    @Query private var logs: [SetLog]
    @State private var month = Date()
    @State private var selected: Date?

    private var marked: Set<Date> { Set(logs.map { Calendar.current.startOfDay(for: $0.date) }) }

    var body: some View {
        NavigationStack {
            ScrollView {
                MonthGrid(month: $month, marked: marked) { selected = $0 }
                    .card().padding(Space.margin).foregroundStyle(Color.textPrimary)
            }
            .background(Color.bg)
            .navigationTitle("Calendar")
            .navigationDestination(item: $selected) { DayDetailView(date: $0) }
        }
    }
}

struct DayDetailView: View {
    let date: Date
    @Query private var sets: [SetLog]
    @Query private var meals: [MealEntry]

    init(date: Date) {
        self.date = date
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start
        _sets = Query(filter: #Predicate<SetLog> { $0.date >= start && $0.date < end }, sort: \.date)
        _meals = Query(filter: #Predicate<MealEntry> { $0.date >= start && $0.date < end }, sort: \.date)
    }

    private var grouped: [(name: String, weight: Double, reps: [Int])] {
        var order: [String] = []; var dict: [String: (Double, [Int])] = [:]
        for s in sets { if dict[s.exerciseName] == nil { order.append(s.exerciseName); dict[s.exerciseName] = (s.weightKg, []) }; dict[s.exerciseName]!.1.append(s.reps) }
        return order.map { (name: $0, weight: dict[$0]!.0, reps: dict[$0]!.1) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(date.formatted(.dateTime.weekday(.wide).day().month(.wide))).font(.system(size: 28, weight: .bold))
                section("Workout", detail: grouped.isEmpty ? nil : "\(grouped.count) exercises") {
                    if grouped.isEmpty { Text("No workout").foregroundStyle(Color.textSecondary) }
                    ForEach(grouped, id: \.name) { g in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(g.name).font(.system(size: 15, weight: .semibold))
                            Text("\(g.weight == 0 ? "BW" : fmt(g.weight) + " kg") × " + g.reps.map(String.init).joined(separator: ", "))
                                .font(.system(size: 13)).foregroundStyle(Color.textSecondary).monospacedDigit()
                        }
                    }
                }
                section("Nutrition", detail: meals.isEmpty ? nil : "\(fmt(meals.reduce(0) { $0 + $1.kcal })) kcal · \(fmt(meals.reduce(0) { $0 + $1.proteinG })) g") {
                    if meals.isEmpty { Text("Nothing logged").foregroundStyle(Color.textSecondary) }
                    ForEach(MealSlot.allCases, id: \.self) { slot in
                        let items = meals.filter { $0.slot == slot }
                        if !items.isEmpty {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(slot.rawValue).font(.system(size: 15, weight: .semibold))
                                Text("\(fmt(items.reduce(0) { $0 + $1.kcal })) kcal · \(fmt(items.reduce(0) { $0 + $1.proteinG })) g")
                                    .font(.system(size: 13)).foregroundStyle(Color.textSecondary).monospacedDigit()
                            }
                        }
                    }
                }
            }.padding(Space.margin).foregroundStyle(Color.textPrimary).frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.bg).navigationBarTitleDisplayMode(.inline)
    }

    private func section<C: View>(_ title: String, detail: String?, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(title).font(.system(size: 20, weight: .bold)).foregroundStyle(Color.yolk)
                Spacer()
                if let detail { Text(detail).font(.system(size: 13)).foregroundStyle(Color.textSecondary) }
            }
            VStack(alignment: .leading, spacing: 16) { content() }
        }
    }
}
