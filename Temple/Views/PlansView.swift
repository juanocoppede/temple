import SwiftUI
import SwiftData

struct PlansView: View {
    @Query(sort: \Plan.name) private var plans: [Plan]
    @Environment(\.modelContext) private var ctx
    @State private var running: Plan?
    @State private var showPicker = false
    @State private var freeBlocks: [WorkoutBlock]?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if plans.isEmpty {
                        VStack(spacing: 6) {
                            Text("No plans yet").font(.system(size: 17, weight: .semibold))
                            Text("Tap + to create your first plan, or start a free workout.").font(.system(size: 13)).foregroundStyle(Color.textSecondary).multilineTextAlignment(.center)
                        }.foregroundStyle(Color.textPrimary).frame(maxWidth: .infinity).padding(.vertical, 32)
                    }
                    ForEach(Array(plans.enumerated()), id: \.element.persistentModelID) { i, plan in
                        let count = plan.blocks.reduce(0) { $0 + $1.exerciseNames.count }
                        let circuits = plan.blocks.filter(\.isCircuit).count
                        HStack(spacing: 12) {
                            NavigationLink { PlanDetailView(plan: plan) } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                Text(plan.name).font(.system(size: 17, weight: .semibold))
                                Text("\(count) exercises" + (circuits > 0 ? " · \(circuits) circuit\(circuits == 1 ? "" : "s")" : ""))
                                    .font(.system(size: 13)).foregroundStyle(Color.textSecondary)
                            }
                            }.buttonStyle(.plain)
                            Spacer()
                            Button("Start") { running = plan }
                                .font(.system(size: 15, weight: .semibold)).foregroundStyle(Color.yolkInk)
                                .padding(.horizontal, 20).frame(height: 40)
                                .background(Color.yolk, in: RoundedRectangle(cornerRadius: Radius.control))
                        }
                        .foregroundStyle(Color.textPrimary).card()
                        .id(i)
                    }
                    Button("Start a free workout") { showPicker = true }
                        .font(.system(size: 17, weight: .semibold)).foregroundStyle(Color.textPrimary)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(Color.raised, in: RoundedRectangle(cornerRadius: Radius.cta))
                }.padding(Space.margin)
            }
            .contentMargins(.bottom, Space.tabBarClearance, for: .scrollContent)
            .background(Color.bg)
            .navigationTitle("Plans")
            .toolbar { ToolbarItem(placement: .primaryAction) { Button { ctx.insert(Plan(name: "New plan")); try? ctx.save() } label: { Image(systemName: "plus") }.tint(Color.yolk) } }
        }
        .fullScreenCover(item: $running) { plan in WorkoutView(planName: plan.name, blocks: plan.workoutBlocks) }
        .fullScreenCover(isPresented: Binding(get: { freeBlocks != nil }, set: { if !$0 { freeBlocks = nil } })) {
            WorkoutView(planName: "Free workout", blocks: freeBlocks ?? [])
        }
        .sheet(isPresented: $showPicker) { FreeWorkoutPicker { freeBlocks = $0 } }
    }
}

/// Builds a free workout out of single exercises and supersets/circuits (exercises done back to back, then rest, repeated for N rounds).
struct FreeWorkoutPicker: View {
    let onStart: ([WorkoutBlock]) -> Void
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Exercise.name) private var exercises: [Exercise]

    struct Item: Identifiable { let id = UUID(); var isGroup: Bool; var names: [String]; var rounds = 3 }
    @State private var items: [Item] = []

    private var valid: [Item] { items.filter { !$0.names.isEmpty } }

    var body: some View {
        NavigationStack {
            List {
                ForEach($items) { $item in
                    Section {
                        ForEach(item.names, id: \.self) { Text($0) }
                            .onDelete { item.names.remove(atOffsets: $0); if item.names.isEmpty { items.removeAll { $0.id == item.id } } }
                            .onMove { item.names.move(fromOffsets: $0, toOffset: $1) }
                        if item.isGroup {
                            Menu("Add exercise to superset") { picker { item.names.append($0) } }
                            Stepper("Rounds: \(item.rounds)", value: $item.rounds, in: 1...10)
                            Button("Remove superset", role: .destructive) { items.removeAll { $0.id == item.id } }
                        }
                    } header: { Text(item.isGroup ? "Superset · \(item.rounds) rounds" : "Single exercise · sets back to back") }
                }
                Section {
                    Menu("Add exercise") { picker { items.append(Item(isGroup: false, names: [$0])) } }
                    Button("Add superset / circuit") { items.append(Item(isGroup: true, names: [])) }
                } footer: {
                    Text("In a superset you do each exercise one after the other, rest, and repeat for the number of rounds.")
                }
            }
            .environment(\.editMode, .constant(.active))
            .scrollContentBackground(.hidden).background(Color.bg)
            .navigationTitle("Free workout").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") {
                        let blocks = valid.map { WorkoutBlock(isCircuit: $0.isGroup, circuitName: $0.isGroup ? "Superset" : nil, names: $0.names, rounds: $0.rounds) }
                        dismiss(); onStart(blocks)
                    }.disabled(valid.isEmpty)
                }
            }
        }.tint(Color.yolk)
    }

    @ViewBuilder private func picker(_ pick: @escaping (String) -> Void) -> some View {
        ForEach(exercises) { ex in Button(ex.name) { pick(ex.name) } }
    }
}
