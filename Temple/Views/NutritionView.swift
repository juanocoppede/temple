import SwiftUI
import SwiftData
import PhotosUI

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

struct ProgressBar: View {
    let title: String; let value: Double; let target: Double; let unit: String
    private var progress: Double { target > 0 ? min(value / target, 1) : 0 }
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(title).font(.system(size: 13, weight: .semibold))
                Spacer()
                Text("\(fmt(value.rounded())) / \(fmt(target)) \(unit)").font(.system(size: 13)).foregroundStyle(Color.textSecondary).monospacedDigit()
            }
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.raised)
                    Capsule().fill(Color.yolk).frame(width: max(progress > 0 ? 8 : 0, g.size.width * progress))
                }
            }.frame(height: 8)
        }
    }
}

struct NutritionView: View {
    @Query private var meals: [MealEntry]
    @Query private var targets: [Targets]
    @State private var addingTo: MealSlot?
    @State private var showSettings = false

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
                    VStack(spacing: 20) {
                        HStack(spacing: 12) {
                            Ring(title: "Calories", value: meals.reduce(0) { $0 + $1.kcal }, target: t.kcal, unit: "kcal")
                            Ring(title: "Protein", value: meals.reduce(0) { $0 + $1.proteinG }, target: t.proteinG, unit: "g")
                        }
                        VStack(spacing: 14) {
                            ProgressBar(title: "Calories", value: meals.reduce(0) { $0 + $1.kcal }, target: t.kcal, unit: "kcal")
                            ProgressBar(title: "Protein", value: meals.reduce(0) { $0 + $1.proteinG }, target: t.proteinG, unit: "g")
                        }
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
            .contentMargins(.bottom, Space.tabBarClearance, for: .scrollContent)
            .background(Color.bg)
            .navigationTitle("Nutrition")
            .toolbar { ToolbarItem(placement: .primaryAction) { Button { showSettings = true } label: { Image(systemName: "gearshape") }.tint(Color.textSecondary) } }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .sheet(item: $addingTo) { slot in AddMealView(slot: slot) }
        }
    }
}

extension MealSlot: Identifiable { var id: String { rawValue } }

struct SettingsView: View {
    @AppStorage("proxyURL") private var proxyURL = ""
    @AppStorage("proxySecret") private var proxySecret = ""
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            Form {
                Section("AI proxy") {
                    TextField("https://temple-ai.you.workers.dev", text: $proxyURL).textInputAutocapitalization(.never).autocorrectionDisabled().keyboardType(.URL)
                    SecureField("App secret", text: $proxySecret)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollContentBackground(.hidden).background(Color.bg)
            .navigationTitle("Settings").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }.tint(Color.yolk)
    }
}

struct AddMealView: View {
    let slot: MealSlot
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dictation = Dictation()
    @State private var showCamera = false
    @State private var aiText = ""
    @State private var pick: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var items: [FoodItem] = []
    @State private var busy = false
    @State private var error: String?
    @State private var name = ""
    @State private var grams = ""
    @State private var kcal = ""
    @State private var protein = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Estimate with AI") {
                    TextField("Describe what you ate", text: $aiText, axis: .vertical)
                    Button { dictation.toggle() } label: { Label(dictation.listening ? "Stop dictation" : "Dictate", systemImage: dictation.listening ? "stop.circle.fill" : "mic") }
                    Button { showCamera = true } label: { Label("Take a photo", systemImage: "camera") }
                    PhotosPicker(selection: $pick, matching: .images) { Label(image == nil ? "Choose from library" : "Photo selected", systemImage: "photo") }
                    Button { Task { await analyze() } } label: { if busy { ProgressView() } else { Text("Analyze") } }
                        .disabled(busy || (aiText.isEmpty && image == nil))
                    if let error { Text(error).font(.footnote).foregroundStyle(Color.destructive) }
                }
                if !items.isEmpty {
                    Section("Review - tap to edit") {
                        ForEach($items) { $item in
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("Food", text: $item.name).font(.headline)
                                HStack(spacing: 16) {
                                    labeled("Grams") { TextField("g", value: $item.grams, format: .number).keyboardType(.decimalPad) }
                                    labeled("Calories") { TextField("kcal", value: $item.kcal, format: .number).keyboardType(.decimalPad) }
                                    labeled("Protein (g)") { TextField("g", value: $item.proteinG, format: .number).keyboardType(.decimalPad) }
                                }.font(.subheadline)
                            }
                        }.onDelete { items.remove(atOffsets: $0) }
                    }
                }
                Section("Add manually to \(slot.rawValue)") {
                    TextField("Food", text: $name)
                    TextField("Grams", text: $grams).keyboardType(.decimalPad)
                    TextField("Calories (kcal)", text: $kcal).keyboardType(.decimalPad)
                    TextField("Protein (g)", text: $protein).keyboardType(.decimalPad)
                }
            }
            .scrollDismissesKeyboard(.immediately)      // dragging/scrolling the form closes the keyboard
            .scrollContentBackground(.hidden).background(Color.bg)
            .navigationTitle("Add to \(slot.rawValue)").navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showCamera) { CameraPicker { image = $0 }.ignoresSafeArea() }
            .onDisappear { dictation.stop() }
            .onChange(of: dictation.text) { _, t in aiText = t }
            .onChange(of: pick) { _, new in
                Task { if let d = try? await new?.loadTransferable(type: Data.self), let img = UIImage(data: d) { image = img } }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) { Spacer(); Button("Done") { hideKeyboard() } }
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.disabled(items.isEmpty && kcal.isEmpty && protein.isEmpty)
                }
            }
        }
        .tint(Color.yolk)
    }

    private func labeled<C: View>(_ title: String, @ViewBuilder _ field: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption).foregroundStyle(Color.textSecondary)
            field().foregroundStyle(Color.textPrimary)
        }
    }

    private func analyze() async {
        dictation.stop()
        busy = true; error = nil
        defer { busy = false }
        do {
            items = try await AIService.analyze(text: aiText, image: image)
            if items.isEmpty { error = "Nothing recognised. Try describing it." }
        } catch { self.error = error.localizedDescription }
    }

    private func save() {
        for i in items { ctx.insert(MealEntry(slot: slot, name: i.name, grams: i.grams, kcal: i.kcal, proteinG: i.proteinG)) }
        if !kcal.isEmpty || !protein.isEmpty {
            ctx.insert(MealEntry(slot: slot, name: name.isEmpty ? slot.rawValue : name, grams: num(grams), kcal: num(kcal), proteinG: num(protein)))
        }
        image = nil      // photos are never stored
        try? ctx.save(); dismiss()
    }
    private func num(_ s: String) -> Double { Double(s.replacingOccurrences(of: ",", with: ".")) ?? 0 }
}
