import SwiftUI
import SwiftData

/// Read-only, visual overview of a plan: each exercise as a card with its photo. Edit opens the editor.
struct PlanDetailView: View {
    @Bindable var plan: Plan
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @State private var running = false

    private var sorted: [PlanBlock] { plan.blocks.sorted { $0.order < $1.order } }
    private func exercise(_ name: String) -> Exercise? { exercises.first { $0.name == name } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                if sorted.isEmpty || sorted.allSatisfy({ $0.exerciseNames.isEmpty }) {
                    Text("This plan has no exercises yet. Tap Edit to add some.")
                        .font(.system(size: 15)).foregroundStyle(Color.textSecondary)
                }
                ForEach(sorted) { block in
                    if !block.exerciseNames.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            if block.isCircuit {
                                HStack {
                                    Text(block.circuitName ?? "Circuit").font(.system(size: 20, weight: .bold)).foregroundStyle(Color.textPrimary)
                                    Spacer()
                                    Text("\(PlanBlock.circuitRounds) rounds").font(.system(size: 13)).foregroundStyle(Color.textSecondary)
                                }
                            }
                            ForEach(block.exerciseNames, id: \.self) { name in card(name) }
                        }
                    }
                }
                Button { running = true } label: { Text("Start workout") }
                    .buttonStyle(PrimaryButton())
                    .disabled(sorted.allSatisfy { $0.exerciseNames.isEmpty })
            }
            .padding(Space.margin).foregroundStyle(Color.textPrimary)
        }
        .contentMargins(.bottom, Space.tabBarClearance, for: .scrollContent)
        .background(Color.bg)
        .navigationTitle(plan.name).navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink { PlanEditorView(plan: plan) } label: { Text("Edit") }.tint(Color.control)
            }
        }
        .fullScreenCover(isPresented: $running) { WorkoutView(planName: plan.name, blocks: plan.workoutBlocks) }
    }

    @ViewBuilder private func card(_ name: String) -> some View {
        if let ex = exercise(name) {
            NavigationLink { ExerciseDetailView(exercise: ex) } label: {
                HStack(spacing: 14) {
                    ExerciseArt(exercise: ex, side: 96, radius: 14)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ex.name).font(.system(size: 17, weight: .semibold)).multilineTextAlignment(.leading)
                        Text("\(ex.muscleGroup) · \(ex.equipment)").font(.system(size: 13)).foregroundStyle(Color.textSecondary)
                        Text(ex.isTimed ? "\(ex.targetSets) sets · \(ex.targetReps) s"
                             : "\(ex.weightKg == 0 ? "+0" : fmt(ex.weightKg)) kg · \(ex.targetSets) × \(ex.targetReps)")
                            .font(.system(size: 13, weight: .medium)).foregroundStyle(Color.textSecondary).monospacedDigit()
                    }
                    Spacer(minLength: 0)
                }
                .padding(10).frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.card, in: RoundedRectangle(cornerRadius: Radius.card))
            }.buttonStyle(.plain)
        } else {
            Text(name).card()
        }
    }
}
