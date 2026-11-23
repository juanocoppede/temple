import SwiftUI
import SwiftData

struct PlanEditorView: View {
    @Bindable var plan: Plan
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Exercise.name) private var exercises: [Exercise]

    private var sorted: [PlanBlock] { plan.blocks.sorted { $0.order < $1.order } }
    private var nextOrder: Int { (plan.blocks.map(\.order).max() ?? -1) + 1 }

    var body: some View {
        List {
            Section("Plan name") { TextField("Name", text: $plan.name) }
            ForEach(sorted) { block in
                Section(block.isCircuit ? "\(block.circuitName ?? "Circuit") · \(PlanBlock.circuitRounds) rounds" : "Single exercise") {
                    ForEach(block.exerciseNames, id: \.self) { Text($0) }
                        .onDelete { offsets in
                            block.exerciseNames.remove(atOffsets: offsets)
                            if block.exerciseNames.isEmpty && !block.isCircuit { remove(block) }
                        }
                        .onMove { block.exerciseNames.move(fromOffsets: $0, toOffset: $1) }
                    if block.isCircuit {
                        Menu("Add exercise to circuit") { picker { block.exerciseNames.append($0) } }
                        Button("Remove circuit", role: .destructive) { remove(block) }
                    }
                }
            }
            Section {
                Menu("Add exercise") { picker { plan.blocks.append(PlanBlock(order: nextOrder, isCircuit: false, exerciseNames: [$0])) } }
                Button("Add circuit") {
                    let letter = String(UnicodeScalar(UInt8(65 + min(plan.blocks.filter(\.isCircuit).count, 25))))
                    plan.blocks.append(PlanBlock(order: nextOrder, isCircuit: true, circuitName: "Circuit \(letter)", exerciseNames: []))
                }
            }
            Section { Button("Delete plan", role: .destructive) { ctx.delete(plan); try? ctx.save(); dismiss() } }
        }
        .environment(\.editMode, .constant(.active))
        .contentMargins(.bottom, Space.tabBarClearance, for: .scrollContent)
        .scrollContentBackground(.hidden).background(Color.bg)
        .navigationTitle("Edit plan").navigationBarTitleDisplayMode(.inline)
        .tint(Color.control)
    }

    @ViewBuilder private func picker(_ pick: @escaping (String) -> Void) -> some View {
        ForEach(exercises) { ex in Button(ex.name) { pick(ex.name) } }
    }
    private func remove(_ block: PlanBlock) {
        plan.blocks.removeAll { $0 === block }
        ctx.delete(block)
    }
}
