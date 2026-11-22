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
            .contentMargins(.bottom, Space.tabBarClearance, for: .scrollContent)
            .background(Color.bg)
            .navigationTitle("Calendar")
            .navigationDestination(item: $selected) { DayDetailView(date: $0) }
        }
    }
}

/// Day view: swipe left/right to move to the next/previous day.
struct DayDetailView: View {
    @State var date: Date
    @State private var forward = true
    init(date: Date) { _date = State(initialValue: date) }

    var body: some View {
        DayContent(date: date)
            .id(date)
            .transition(.asymmetric(insertion: .move(edge: forward ? .trailing : .leading), removal: .move(edge: forward ? .leading : .trailing)).combined(with: .opacity))
            .contentShape(Rectangle())
            .simultaneousGesture(DragGesture(minimumDistance: 30).onEnded { v in
                guard abs(v.translation.width) > 60, abs(v.translation.width) > abs(v.translation.height) * 1.5 else { return }
                let step = v.translation.width < 0 ? 1 : -1
                forward = step > 0
                withAnimation(.easeInOut(duration: 0.25)) { date = Calendar.current.date(byAdding: .day, value: step, to: date) ?? date }
            })
            .clipped()
    }
}

/// Date to store for an entry added to `day`: now if it is today, otherwise midday of that day.
func entryDate(for day: Date) -> Date {
    let cal = Calendar.current
    if cal.isDateInToday(day) { return .now }
    return cal.date(bySettingHour: 12, minute: 0, second: 0, of: day) ?? day
}

struct ExerciseTarget: Identifiable { let id = UUID(); let name: String? }
struct CircuitTarget: Identifiable { let id = UUID(); let name: String? }

struct DayContent: View {
    let date: Date
    @Environment(\.modelContext) private var ctx
    @Query private var sets: [SetLog]
    @Query private var meals: [MealEntry]
    @Query private var targets: [Targets]
    @State private var addingSlot: MealSlot?
    @State private var editingMeal: MealEntry?
    @State private var editingExercise: ExerciseTarget?
    @State private var editingCircuit: CircuitTarget?
    @Query private var exercises: [Exercise]
    private var t: Targets { targets.first ?? Targets() }

    init(date: Date) {
        self.date = date
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start
        _sets = Query(filter: #Predicate<SetLog> { $0.date >= start && $0.date < end }, sort: \.date)
        _meals = Query(filter: #Predicate<MealEntry> { $0.date >= start && $0.date < end }, sort: \.date)
    }

    struct DayBlock: Identifiable {
        var id: String { circuit ?? "single-" + (rows.first?.name ?? "") }
        let circuit: String?
        var rows: [(name: String, weight: Double, reps: [Int])]
    }
    /// Sets of the day in the order they were done: circuits (Circuit A, Circuit B…) and single exercises.
    private var blocks: [DayBlock] {
        var out: [DayBlock] = []
        for s in sets {
            let row = (name: s.exerciseName, weight: s.weightKg, reps: [s.reps])
            if let c = s.circuitName {
                if let bi = out.firstIndex(where: { $0.circuit == c }) {
                    if let ri = out[bi].rows.firstIndex(where: { $0.name == s.exerciseName }) { out[bi].rows[ri].reps.append(s.reps) }
                    else { out[bi].rows.append(row) }
                } else { out.append(DayBlock(circuit: c, rows: [row])) }
            } else if let bi = out.firstIndex(where: { $0.circuit == nil && $0.rows.first?.name == s.exerciseName }) {
                out[bi].rows[0].reps.append(s.reps)
            } else { out.append(DayBlock(circuit: nil, rows: [row])) }
        }
        return out
    }

    @ViewBuilder private func art(_ name: String) -> some View {
        if let ex = exercises.first(where: { $0.name == name }) { ExerciseArt(exercise: ex, side: 52, radius: 12) }
        else { Color.raised.frame(width: 52, height: 52).clipShape(RoundedRectangle(cornerRadius: 12)) }
    }

    private func rowView(_ r: (name: String, weight: Double, reps: [Int]), chevron: Bool) -> some View {
        HStack(spacing: 12) {
            art(r.name)
            VStack(alignment: .leading, spacing: 2) {
                Text(r.name).font(.system(size: 15, weight: .semibold))
                Text("\(r.weight == 0 ? "BW" : fmt(r.weight) + " kg") × " + r.reps.map(String.init).joined(separator: ", "))
                    .font(.system(size: 13)).foregroundStyle(Color.textSecondary).monospacedDigit()
            }
            Spacer()
            if chevron { Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.textSecondary) }
        }.contentShape(Rectangle())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(date.formatted(.dateTime.weekday(.wide).day().month(.wide))).font(.system(size: 28, weight: .bold))
                section("Workout", detail: blocks.isEmpty ? nil : "\(blocks.reduce(0) { $0 + $1.rows.count }) exercises") {
                    if blocks.isEmpty { Text("No workout").foregroundStyle(Color.textSecondary) }
                    ForEach(blocks) { block in
                        if let c = block.circuit {
                            VStack(alignment: .leading, spacing: 12) {
                                Button { editingCircuit = CircuitTarget(name: c) } label: {
                                    HStack {
                                        Text(c).font(.system(size: 17, weight: .bold))
                                        Text("· \(block.rows.map { $0.reps.count }.max() ?? 0) rounds").font(.system(size: 13)).foregroundStyle(Color.textSecondary)
                                        Spacer()
                                        Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.textSecondary)
                                    }.contentShape(Rectangle())
                                }.buttonStyle(.plain)
                                ForEach(block.rows, id: \.name) { r in rowView(r, chevron: false) }
                            }
                            .padding(Space.inCard).frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.card, in: RoundedRectangle(cornerRadius: Radius.card))
                        } else if let r = block.rows.first {
                            Button { editingExercise = ExerciseTarget(name: r.name) } label: { rowView(r, chevron: true) }.buttonStyle(.plain)
                        }
                    }
                    HStack(spacing: 20) {
                        Button { editingExercise = ExerciseTarget(name: nil) } label: { Label("Add exercise", systemImage: "plus") }
                        Button { editingCircuit = CircuitTarget(name: nil) } label: { Label("Add circuit", systemImage: "plus.circle") }
                    }.font(.system(size: 15, weight: .semibold)).foregroundStyle(Color.yolk)
                }
                section("Nutrition", detail: meals.isEmpty ? nil : "\(fmt(meals.reduce(0) { $0 + $1.kcal })) kcal · \(fmt(meals.reduce(0) { $0 + $1.proteinG })) g") {
                    VStack(spacing: 14) {
                        ProgressBar(title: "Calories", value: meals.reduce(0) { $0 + $1.kcal }, target: t.kcal, unit: "kcal")
                        ProgressBar(title: "Protein", value: meals.reduce(0) { $0 + $1.proteinG }, target: t.proteinG, unit: "g")
                    }
                    ForEach(MealSlot.allCases, id: \.self) { slot in
                        let items = meals.filter { $0.slot == slot }
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(slot.rawValue).font(.system(size: 15, weight: .semibold))
                                Spacer()
                                Button("Add") { addingSlot = slot }.font(.system(size: 15, weight: .semibold)).foregroundStyle(Color.yolk).frame(minWidth: 44, minHeight: 32)
                            }
                            ForEach(items) { m in
                                Button { editingMeal = m } label: {
                                    HStack {
                                        Text(m.name).font(.system(size: 15, weight: .semibold)).foregroundStyle(Color.textSecondary)
                                        Spacer()
                                        Text("\(fmt(m.kcal)) kcal").font(.system(size: 13)).monospacedDigit()
                                        Text("\(fmt(m.proteinG)) g").font(.system(size: 13)).monospacedDigit().frame(width: 52, alignment: .trailing)
                                    }.contentShape(Rectangle())
                                }.buttonStyle(.plain)
                            }
                            if !items.isEmpty {
                                Divider().overlay(Color.white.opacity(0.1))
                                HStack {
                                    Text("Total").font(.system(size: 13, weight: .bold))
                                    Spacer()
                                    Text("\(fmt(items.reduce(0) { $0 + $1.kcal })) kcal").font(.system(size: 13, weight: .bold)).monospacedDigit()
                                    Text("\(fmt(items.reduce(0) { $0 + $1.proteinG })) g").font(.system(size: 13, weight: .bold)).monospacedDigit().frame(width: 52, alignment: .trailing)
                                }
                            }
                        }
                    }
                }
            }.padding(Space.margin).foregroundStyle(Color.textPrimary).frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentMargins(.bottom, Space.tabBarClearance, for: .scrollContent)
        .background(Color.bg).navigationBarTitleDisplayMode(.inline)
        .sheet(item: $addingSlot) { AddMealView(slot: $0, date: date) }
        .sheet(item: $editingMeal) { EditMealView(meal: $0) }
        .sheet(item: $editingExercise) { DayExerciseEditor(date: date, target: $0) }
        .sheet(item: $editingCircuit) { DayCircuitEditor(date: date, target: $0) }
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

struct EditMealView: View {
    @Bindable var meal: MealEntry
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            Form {
                Section("Meal") {
                    TextField("Food", text: $meal.name)
                    TextField("Grams", value: $meal.grams, format: .number).keyboardType(.decimalPad)
                    TextField("Calories (kcal)", value: $meal.kcal, format: .number).keyboardType(.decimalPad)
                    TextField("Protein (g)", value: $meal.proteinG, format: .number).keyboardType(.decimalPad)
                }
                Section { Button("Delete", role: .destructive) { ctx.delete(meal); try? ctx.save(); dismiss() } }
            }
            .scrollDismissesKeyboard(.immediately)
            .scrollContentBackground(.hidden).background(Color.bg)
            .navigationTitle("Edit meal").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { try? ctx.save(); dismiss() } } }
        }.tint(Color.yolk)
    }
}

/// Add or edit one exercise's sets for a given day (weight + reps per set).
struct DayExerciseEditor: View {
    let date: Date
    let target: ExerciseTarget
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @State private var name = ""
    @State private var weight: Double = 0
    @State private var reps: [Int] = [10]
    @State private var existing = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise") {
                    if target.name == nil {
                        Picker("Exercise", selection: $name) {
                            Text("Choose…").tag("")
                            ForEach(exercises) { Text($0.name).tag($0.name) }
                        }
                    } else { Text(name) }
                }
                Section("Weight (kg, 0 = bodyweight)") { TextField("0", value: $weight, format: .number).keyboardType(.decimalPad) }
                Section("Sets") {
                    ForEach(reps.indices, id: \.self) { i in
                        Stepper("Set \(i + 1): \(reps[i])", value: $reps[i], in: 0...300)
                    }.onDelete { reps.remove(atOffsets: $0) }
                    Button("Add set") { reps.append(reps.last ?? 10) }
                }
                if existing { Section { Button("Remove from this day", role: .destructive) { removeLogs(); try? ctx.save(); dismiss() } } }
            }
            .scrollDismissesKeyboard(.immediately)
            .scrollContentBackground(.hidden).background(Color.bg)
            .navigationTitle(target.name == nil ? "Add exercise" : "Edit exercise").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save() }.disabled(name.isEmpty || reps.isEmpty) }
            }
            .onAppear { load() }
            .onChange(of: name) { _, n in
                if target.name == nil, let ex = exercises.first(where: { $0.name == n }) { weight = ex.weightKg }
            }
        }.tint(Color.yolk)
    }

    private func logs(for n: String) -> [SetLog] {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start
        let d = FetchDescriptor<SetLog>(predicate: #Predicate { $0.date >= start && $0.date < end && $0.exerciseName == n }, sortBy: [SortDescriptor(\.setNumber), SortDescriptor(\.date)])
        return (try? ctx.fetch(d)) ?? []
    }
    private func load() {
        guard let n = target.name else { return }
        name = n
        let l = logs(for: n)
        if !l.isEmpty { weight = l[0].weightKg; reps = l.map(\.reps); existing = true }
    }
    private func removeLogs() { for l in logs(for: name) { ctx.delete(l) } }
    private func save() {
        removeLogs()
        let when = entryDate(for: date)
        for (i, r) in reps.enumerated() { ctx.insert(SetLog(exerciseName: name, weightKg: weight, reps: r, setNumber: i + 1, date: when)) }
        try? ctx.save(); dismiss()
    }
}

/// Add or edit a circuit (exercises done in order, repeated for N rounds) on a given day.
struct DayCircuitEditor: View {
    let date: Date
    let target: CircuitTarget
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Exercise.name) private var exercises: [Exercise]

    struct Row: Identifiable { let id = UUID(); var name: String; var weight: Double; var reps: [Int] }
    @State private var name = ""
    @State private var rounds = 3
    @State private var rows: [Row] = []
    @State private var existing = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Circuit") {
                    TextField("Name", text: $name)
                    Stepper("Rounds: \(rounds)", value: $rounds, in: 1...10)
                }
                ForEach($rows) { $row in
                    Section {
                        Text(row.name).font(.headline)
                        HStack { Text("Weight (kg)"); Spacer(); TextField("0", value: $row.weight, format: .number).keyboardType(.decimalPad).multilineTextAlignment(.trailing).frame(width: 90) }
                        ForEach(row.reps.indices, id: \.self) { i in Stepper("Round \(i + 1): \(row.reps[i])", value: $row.reps[i], in: 0...300) }
                        Button("Remove exercise", role: .destructive) { rows.removeAll { $0.id == row.id } }
                    }
                }
                Section {
                    Menu("Add exercise to circuit") {
                        ForEach(exercises) { ex in Button(ex.name) { rows.append(Row(name: ex.name, weight: ex.weightKg, reps: Array(repeating: ex.targetReps > 0 ? ex.targetReps : 10, count: rounds))) } }
                    }
                }
                if existing { Section { Button("Remove circuit from this day", role: .destructive) { removeLogs(); try? ctx.save(); dismiss() } } }
            }
            .scrollDismissesKeyboard(.immediately)
            .scrollContentBackground(.hidden).background(Color.bg)
            .navigationTitle(target.name == nil ? "Add circuit" : "Edit circuit").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save() }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || rows.isEmpty) }
            }
            .onAppear { load() }
            .onChange(of: rounds) { _, n in
                for i in rows.indices {
                    while rows[i].reps.count < n { rows[i].reps.append(rows[i].reps.last ?? 10) }
                    while rows[i].reps.count > n { rows[i].reps.removeLast() }
                }
            }
        }.tint(Color.yolk)
    }

    private func daySets() -> [SetLog] {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start
        let d = FetchDescriptor<SetLog>(predicate: #Predicate { $0.date >= start && $0.date < end }, sortBy: [SortDescriptor(\.date)])
        return (try? ctx.fetch(d)) ?? []
    }
    private func load() {
        let day = daySets()
        guard let n = target.name else {
            let used = Set(day.compactMap(\.circuitName))
            name = (65...90).map { "Circuit " + String(UnicodeScalar(UInt8($0))) }.first { !used.contains($0) } ?? "Circuit"
            return
        }
        name = n
        var out: [Row] = []
        for l in day where l.circuitName == n {
            if let i = out.firstIndex(where: { $0.name == l.exerciseName }) { out[i].reps.append(l.reps) }
            else { out.append(Row(name: l.exerciseName, weight: l.weightKg, reps: [l.reps])) }
        }
        rows = out; rounds = out.map { $0.reps.count }.max() ?? 3; existing = !out.isEmpty
    }
    private func removeLogs() { for l in daySets() where l.circuitName == (target.name ?? "\u{0}") { ctx.delete(l) } }
    private func save() {
        removeLogs()
        let base = entryDate(for: date)
        let n = name.trimmingCharacters(in: .whitespaces)
        for r in 0..<rounds {
            for (ri, row) in rows.enumerated() where r < row.reps.count {
                ctx.insert(SetLog(exerciseName: row.name, weightKg: row.weight, reps: row.reps[r], setNumber: r + 1, circuitName: n, date: base.addingTimeInterval(Double(r * rows.count + ri))))
            }
        }
        try? ctx.save(); dismiss()
    }
}
