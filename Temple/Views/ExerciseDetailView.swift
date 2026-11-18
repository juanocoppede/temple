import SwiftUI
import SwiftData
import Charts

struct ExerciseDetailView: View {
    let exercise: Exercise
    @Query private var logs: [SetLog]
    @State private var month = Date()

    init(exercise: Exercise) {
        self.exercise = exercise
        let n = exercise.name
        _logs = Query(filter: #Predicate<SetLog> { $0.exerciseName == n }, sort: \.date)
    }

    private var points: [(date: Date, kg: Double)] {
        let cal = Calendar.current
        let byDay = Dictionary(grouping: logs) { cal.startOfDay(for: $0.date) }
        return byDay.map { (date: $0.key, kg: $0.value.map(\.weightKg).max() ?? 0) }.sorted { $0.date < $1.date }
    }
    private var marked: Set<Date> { Set(logs.map { Calendar.current.startOfDay(for: $0.date) }) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name).font(.system(size: 28, weight: .bold))
                    Text("\(exercise.muscleGroup) · \(exercise.equipment)").font(.system(size: 15)).foregroundStyle(Color.textSecondary)
                    Text("Currently using \(fmt(exercise.weightKg)) kg · \(exercise.targetSets) × \(exercise.targetReps)").font(.system(size: 15)).foregroundStyle(Color.textSecondary)
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("Weight").font(.system(size: 20, weight: .bold)).foregroundStyle(Color.yolk)
                    if points.count < 2 { Text("The chart appears after two sessions.").foregroundStyle(Color.textSecondary).font(.system(size: 13)) }
                    else {
                        Chart(points, id: \.date) { p in
                            LineMark(x: .value("Date", p.date), y: .value("kg", p.kg)).foregroundStyle(Color.yolk)
                            PointMark(x: .value("Date", p.date), y: .value("kg", p.kg)).foregroundStyle(Color.yolk)
                        }.frame(height: 160)
                    }
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("Calendar").font(.system(size: 20, weight: .bold)).foregroundStyle(Color.yolk)
                    MonthGrid(month: $month, marked: marked)
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("History").font(.system(size: 20, weight: .bold)).foregroundStyle(Color.yolk)
                    if logs.isEmpty { Text("Not done yet").foregroundStyle(Color.textSecondary) }
                    ForEach(Array(Dictionary(grouping: logs) { Calendar.current.startOfDay(for: $0.date) }.sorted { $0.key > $1.key }), id: \.key) { day, sets in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(day.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))).font(.system(size: 15, weight: .semibold))
                            Text("\(fmt(sets[0].weightKg)) kg × " + sets.map { String($0.reps) }.joined(separator: ", ")).font(.system(size: 13)).foregroundStyle(Color.textSecondary).monospacedDigit()
                        }
                    }
                }
            }.padding(Space.margin).foregroundStyle(Color.textPrimary).frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.bg).navigationBarTitleDisplayMode(.inline)
    }
}
