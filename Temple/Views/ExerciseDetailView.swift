import SwiftUI
import SwiftData
import Charts

struct ExerciseDetailView: View {
    let exercise: Exercise
    @Query private var logs: [SetLog]
    
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
    private var last7: [Date] {
        let cal = Calendar.current, today = cal.startOfDay(for: .now)
        return (0..<7).reversed().compactMap { cal.date(byAdding: .day, value: -$0, to: today) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 36) {
                ExerciseArt(exercise: exercise, portrait: true, radius: 24)
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name).font(.system(size: 28, weight: .bold))
                    Text("\(exercise.muscleGroup) · \(exercise.equipment)").font(.system(size: 15)).foregroundStyle(Color.textSecondary)
                    Text("Currently using \(fmt(exercise.weightKg)) kg · \(exercise.targetSets) × \(exercise.targetReps)").font(.system(size: 15)).foregroundStyle(Color.textSecondary)
                }
                if let n = exercise.illustration, let img = UIImage(named: n + "-musc") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Muscles worked").font(.system(size: 20, weight: .bold)).foregroundStyle(Color.textPrimary)
                        Image(uiImage: img).resizable().scaledToFit().frame(maxWidth: .infinity)
                            .background(Color.white).clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                }
                if !exercise.tips.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How to do it").font(.system(size: 20, weight: .bold)).foregroundStyle(Color.textPrimary)
                        TipsList(tips: exercise.tips)
                    }
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("Weight").font(.system(size: 20, weight: .bold)).foregroundStyle(Color.textPrimary)
                    if points.count < 2 { Text("The chart appears after two sessions.").foregroundStyle(Color.textSecondary).font(.system(size: 13)) }
                    else {
                        Chart(points, id: \.date) { p in
                            LineMark(x: .value("Date", p.date), y: .value("kg", p.kg)).foregroundStyle(Color.yolk)
                            PointMark(x: .value("Date", p.date), y: .value("kg", p.kg)).foregroundStyle(Color.yolk)
                        }.frame(height: 160)
                    }
                }
                VStack(alignment: .leading, spacing: 16) {
                    Text("Last 7 days").font(.system(size: 20, weight: .bold)).foregroundStyle(Color.textPrimary)
                    HStack(spacing: 0) {
                        ForEach(last7, id: \.self) { d in
                            let sets = logs.filter { Calendar.current.isDate($0.date, inSameDayAs: d) }
                            let isToday = Calendar.current.isDateInToday(d)
                            VStack(spacing: 8) {
                                Text(d.formatted(.dateTime.weekday(.abbreviated))).font(.system(size: 11, weight: isToday ? .bold : .medium))
                                    .foregroundStyle(isToday ? Color.yolk : Color.textSecondary).lineLimit(1).minimumScaleFactor(0.7)
                                ZStack {
                                    Circle().fill(sets.isEmpty ? Color.clear : Color.yolk)
                                    Circle().stroke(sets.isEmpty ? Color.raised : Color.clear, lineWidth: 2)
                                    if !sets.isEmpty { Image(systemName: "checkmark").font(.system(size: 15, weight: .bold)).foregroundStyle(Color.yolkInk) }
                                }.frame(width: 36, height: 36)
                                Text("\(Calendar.current.component(.day, from: d))").font(.system(size: 11)).foregroundStyle(Color.textSecondary).monospacedDigit()
                            }.frame(maxWidth: .infinity)
                        }
                    }
                }
            }.padding(Space.margin).foregroundStyle(Color.textPrimary).frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentMargins(.bottom, Space.tabBarClearance, for: .scrollContent)
        .background(Color.bg).navigationBarTitleDisplayMode(.inline)
    }
}
