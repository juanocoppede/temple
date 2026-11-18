import SwiftUI
import SwiftData

struct WorkoutStep {
    let exercise: Exercise
    let number: Int          // set number, or round number inside a circuit
    let total: Int
    let blockIndex: Int
    let circuit: String?
    let circuitOrder: [String]
}

struct WorkoutView: View {
    let plan: Plan
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss
    @Query private var allExercises: [Exercise]

    @State private var index = 0
    @State private var reps = 0
    @State private var done: [Int: Int] = [:]       // step index -> reps logged
    @State private var session: WorkoutSession?

    private var steps: [WorkoutStep] {
        let byName = Dictionary(uniqueKeysWithValues: allExercises.map { ($0.name, $0) })
        var out: [WorkoutStep] = []
        for (bi, block) in plan.blocks.sorted(by: { $0.order < $1.order }).enumerated() {
            let exs = block.exerciseNames.compactMap { byName[$0] }
            if block.isCircuit {
                for round in 1...PlanBlock.circuitRounds {
                    for ex in exs { out.append(WorkoutStep(exercise: ex, number: round, total: PlanBlock.circuitRounds, blockIndex: bi, circuit: block.circuitName ?? "Circuit", circuitOrder: exs.map(\.name))) }
                }
            } else {
                for ex in exs { for s in 1...max(ex.targetSets, 1) { out.append(WorkoutStep(exercise: ex, number: s, total: max(ex.targetSets, 1), blockIndex: bi, circuit: nil, circuitOrder: [])) } }
            }
        }
        return out
    }

    var body: some View {
        let all = steps
        VStack(spacing: 20) {
            HStack {
                Button("Close") { dismiss() }.foregroundStyle(Color.textSecondary)
                Spacer()
                Text(plan.name).font(.system(size: 17, weight: .semibold))
                Spacer()
                Button("Finish") { dismiss() }.fontWeight(.semibold).foregroundStyle(Color.yolk)
            }.font(.system(size: 17)).frame(height: 44)

            if index < all.count {
                let step = all[index]
                content(step: step, all: all)
            } else {
                Spacer()
                Text("Workout complete").font(.system(size: 28, weight: .bold))
                Button("Done") { dismiss() }.buttonStyle(PrimaryButton())
                Spacer()
            }
        }
        .foregroundStyle(Color.textPrimary)
        .padding(.horizontal, Space.margin).padding(.bottom, 28)
        .background(Color.bg.ignoresSafeArea())
        .onAppear { if let s = all.first { reps = s.exercise.targetReps } }
    }

    @ViewBuilder private func content(step: WorkoutStep, all: [WorkoutStep]) -> some View {
        let ex = step.exercise
        if let c = step.circuit {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(step.circuitOrder.enumerated()), id: \.offset) { i, name in
                        Text("\(i + 1) \(name)").font(.system(size: 13, weight: name == ex.name ? .semibold : .regular)).lineLimit(1)
                            .foregroundStyle(name == ex.name ? Color.yolk : Color.textSecondary)
                            .padding(.horizontal, 12).frame(height: 28)
                            .background(name == ex.name ? Color.yolkSoft : Color.card, in: Capsule())
                        if i < step.circuitOrder.count - 1 { Image(systemName: "arrow.right").font(.system(size: 12)).foregroundStyle(Color.textSecondary) }
                    }
                }
            }
            Text("\(c) · ROUND \(step.number) OF \(step.total)").font(.system(size: 12, weight: .semibold)).tracking(0.7).foregroundStyle(Color.yolk).frame(maxWidth: .infinity, alignment: .leading)
        }
        VStack(alignment: .leading, spacing: 4) {
            Text(ex.name).font(.system(size: 28, weight: .bold))
            Text("Currently using \(fmt(ex.weightKg)) kg · \(ex.targetSets) × \(ex.targetReps)").font(.system(size: 15)).foregroundStyle(Color.textSecondary)
        }.frame(maxWidth: .infinity, alignment: .leading)

        stepper(title: nil, value: "\(fmt(ex.weightKg))", unit: "kg", minus: { ex.weightKg = max(0, ex.weightKg - 1) }, plus: { ex.weightKg += 1 })
        stepper(title: "Reps", value: "\(reps)", unit: ex.isTimed ? "s" : "reps", minus: { reps = max(0, reps - 1) }, plus: { reps += 1 })

        let siblings = all.enumerated().filter { $0.element.blockIndex == step.blockIndex && $0.element.exercise.name == ex.name }
        HStack(spacing: 10) {
            ForEach(siblings, id: \.offset) { i, s in
                let label = step.circuit != nil ? "Round \(s.number)" : "Set \(s.number)"
                let isCurrent = i == index
                VStack(spacing: 0) {
                    Text(done[i].map(String.init) ?? "–").font(.system(size: 24, weight: .bold)).monospacedDigit()
                    Text(label).font(.system(size: 12, weight: .semibold)).foregroundStyle(done[i] != nil ? Color.yolkInk : Color.textSecondary)
                }
                .frame(maxWidth: .infinity, minHeight: 72)
                .foregroundStyle(done[i] != nil ? Color.yolkInk : Color.textPrimary)
                .background(done[i] != nil ? Color.yolk : Color.card, in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.yolk, lineWidth: isCurrent ? 1.5 : 0))
            }
        }
        Spacer()
        Button(step.circuit != nil ? "Complete round \(step.number)" : "Complete set \(step.number)") { complete(step: step, all: all) }
            .buttonStyle(PrimaryButton())
    }

    private func stepper(title: String?, value: String, unit: String, minus: @escaping () -> Void, plus: @escaping () -> Void) -> some View {
        HStack {
            Button(action: minus) { Image(systemName: "minus").font(.system(size: 20, weight: .semibold)).frame(width: 52, height: 52).background(Color.raised, in: RoundedRectangle(cornerRadius: Radius.control)) }
            Spacer()
            (Text(value).font(.system(size: 34, weight: .bold)).monospacedDigit() + Text(" \(unit)").font(.system(size: 17, weight: .medium)).foregroundColor(Color.textSecondary))
            Spacer()
            Button(action: plus) { Image(systemName: "plus").font(.system(size: 20, weight: .semibold)).frame(width: 52, height: 52).background(Color.raised, in: RoundedRectangle(cornerRadius: Radius.control)) }
        }
        .buttonStyle(.plain).padding(6).background(Color.card, in: RoundedRectangle(cornerRadius: Radius.cta))
    }

    private func complete(step: WorkoutStep, all: [WorkoutStep]) {
        let s = session ?? { let n = WorkoutSession(planName: plan.name); ctx.insert(n); session = n; return n }()
        let log = SetLog(exerciseName: step.exercise.name, weightKg: step.exercise.weightKg, reps: reps, setNumber: step.number, circuitName: step.circuit)
        ctx.insert(log); s.sets.append(log)
        done[index] = reps
        try? ctx.save()
        index += 1
        if index < all.count { reps = all[index].exercise.targetReps }
    }
}
