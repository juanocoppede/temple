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
                VStack(spacing: 16) {
                    ForEach(Array(plans.enumerated()), id: \.element.persistentModelID) { i, plan in
                        let count = plan.blocks.reduce(0) { $0 + $1.exerciseNames.count }
                        let circuits = plan.blocks.filter(\.isCircuit).count
                        HStack(spacing: 12) {
                            NavigationLink { PlanEditorView(plan: plan) } label: {
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
            .background(Color.bg)
            .navigationTitle("Plans")
            .toolbar { ToolbarItem(placement: .primaryAction) { Button { ctx.insert(Plan(name: "New plan")); try? ctx.save() } label: { Image(systemName: "plus") }.tint(Color.yolk) } }
        }
        .fullScreenCover(item: $running) { plan in WorkoutView(planName: plan.name, blocks: plan.workoutBlocks) }
        .fullScreenCover(isPresented: Binding(get: { freeBlocks != nil }, set: { if !$0 { freeBlocks = nil } })) {
            WorkoutView(planName: "Free workout", blocks: freeBlocks ?? [])
        }
        .sheet(isPresented: $showPicker) { FreeWorkoutPicker { names in freeBlocks = names.map { WorkoutBlock(isCircuit: false, circuitName: nil, names: [$0]) } } }
    }
}

struct FreeWorkoutPicker: View {
    let onStart: ([String]) -> Void
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @State private var chosen: [String] = []     // keeps tap order

    var body: some View {
        NavigationStack {
            List(exercises) { ex in
                Button {
                    if let i = chosen.firstIndex(of: ex.name) { chosen.remove(at: i) } else { chosen.append(ex.name) }
                } label: {
                    HStack {
                        Text(ex.name).foregroundStyle(Color.textPrimary)
                        Spacer()
                        if let i = chosen.firstIndex(of: ex.name) { Text("\(i + 1)").foregroundStyle(Color.yolk).fontWeight(.semibold) }
                    }
                }
            }
            .scrollContentBackground(.hidden).background(Color.bg)
            .navigationTitle("Pick exercises").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") { let n = chosen; dismiss(); onStart(n) }.disabled(chosen.isEmpty)
                }
            }
        }.tint(Color.yolk)
    }
}
