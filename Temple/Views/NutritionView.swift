import SwiftUI
import SwiftData

struct Ring: View {
    let title: String; let value: Double; let target: Double; let unit: String
    private var progress: Double { target > 0 ? min(value / target, 1) : 0 }
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle().stroke(Color.raised, lineWidth: 12)
                Circle().trim(from: 0, to: progress).stroke(Color.yolk, style: StrokeStyle(lineWidth: 12, lineCap: .round)).rotationEffect(.degrees(-90))
                VStack(spacing: 0) {
                    Text(fmt(value.rounded())).font(.system(size: 24, weight: .bold)).monospacedDigit()
                    Text("of \(fmt(target)) \(unit)").font(.system(size: 12)).foregroundStyle(Color.textSecondary)
                }
            }.frame(width: 140, height: 140)
            Text(title).font(.system(size: 15, weight: .semibold))
        }.frame(maxWidth: .infinity)
    }
}

struct NutritionView: View {
    @Query private var meals: [MealEntry]
    @Query private var targets: [Targets]
    @State private var addingTo: MealSlot?

    init() {
        let start = Calendar.current.startOfDay(for: .now)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start
        _meals = Query(filter: #Predicate<MealEntry> { $0.date >= start && $0.date < end }, sort: \.date)
    }

    private var t: Targets { targets.first ?? Targets() }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    HStack(spacing: 12) {
                        Ring(title: "Calories", value: meals.reduce(0) { $0 + $1.kcal }, target: t.kcal, unit: "kcal")
                        Ring(title: "Protein", value: meals.reduce(0) { $0 + $1.proteinG }, target: t.proteinG, unit: "g")
                    }.card()
                    ForEach(MealSlot.allCases, id: \.self) { slot in
                        let items = meals.filter { $0.slot == slot }
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(slot.rawValue).font(.system(size: 20, weight: .bold)).foregroundStyle(Color.yolk)
                                Spacer()
                                Button("Add") { addingTo = slot }.font(.system(size: 15, weight: .semibold)).foregroundStyle(Color.yolk).frame(minWidth: 44, minHeight: 44)
                            }
                            if items.isEmpty { Text("—").foregroundStyle(Color.textSecondary) }
                            ForEach(items) { m in
                                HStack {
                                    Text(m.name).font(.system(size: 15, weight: .semibold))
                                    Spacer()
                                    Text("\(fmt(m.kcal)) kcal").font(.system(size: 15, weight: .semibold)).monospacedDigit().frame(width: 84, alignment: .trailing)
                                    Text("\(fmt(m.proteinG)) g").font(.system(size: 15, weight: .semibold)).monospacedDigit().frame(width: 52, alignment: .trailing)
                                }
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                }.padding(Space.margin).foregroundStyle(Color.textPrimary)
            }
            .background(Color.bg)
            .navigationTitle("Nutrition")
            .sheet(item: $addingTo) { slot in AddMealView(slot: slot) }
        }
    }
}

extension MealSlot: Identifiable { var id: String { rawValue } }

struct AddMealView: View {
    let slot: MealSlot
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var grams = ""
    @State private var kcal = ""
    @State private var protein = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Add to \(slot.rawValue)") {
                    TextField("Food", text: $name)
                    TextField("Grams", text: $grams).keyboardType(.decimalPad)
                    TextField("Calories (kcal)", text: $kcal).keyboardType(.decimalPad)
                    TextField("Protein (g)", text: $protein).keyboardType(.decimalPad)
                }
            }
            .scrollContentBackground(.hidden).background(Color.bg)
            .navigationTitle("Add meal").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        ctx.insert(MealEntry(slot: slot, name: name.isEmpty ? slot.rawValue : name, grams: num(grams), kcal: num(kcal), proteinG: num(protein)))
                        try? ctx.save(); dismiss()
                    }.disabled(kcal.isEmpty && protein.isEmpty)
                }
            }
        }
        .tint(Color.yolk)
    }
    private func num(_ s: String) -> Double { Double(s.replacingOccurrences(of: ",", with: ".")) ?? 0 }
}
