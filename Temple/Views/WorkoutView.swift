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

struct WorkoutBlock {
    let isCircuit: Bool
    let circuitName: String?
    let names: [String]
    var rounds: Int = PlanBlock.circuitRounds
}

extension Plan {
    var workoutBlocks: [WorkoutBlock] {
        blocks.sorted { $0.order < $1.order }.map { WorkoutBlock(isCircuit: $0.isCircuit, circuitName: $0.circuitName, names: $0.exerciseNames) }
    }
}

struct WorkoutView: View {
    let planName: String
    let blocks: [WorkoutBlock]
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss
    @Query private var allExercises: [Exercise]

    @State private var index = 0
    @State private var reps = 0
    @State private var done: [Int: Int] = [:]       // step index -> reps logged
    @State private var session: WorkoutSession?
    @State private var showTips = false
    @State private var restStart: Date?             // set between rounds of a circuit; never saved

    private var steps: [WorkoutStep] {
        let byName = Dictionary(uniqueKeysWithValues: allExercises.map { ($0.name, $0) })
        var out: [WorkoutStep] = []
        for (bi, block) in blocks.enumerated() {
            let exs = block.names.compactMap { byName[$0] }
            if block.isCircuit {
                for round in 1...max(block.rounds, 1) {
                    for ex in exs { out.append(WorkoutStep(exercise: ex, number: round, total: max(block.rounds, 1), blockIndex: bi, circuit: block.circuitName ?? "Circuit", circuitOrder: exs.map(\.name))) }
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
                Text(planName).font(.system(size: 17, weight: .semibold))
                Spacer()
                Button("Finish") { dismiss() }.fontWeight(.semibold).foregroundStyle(Color.control)
            }.font(.system(size: 17)).frame(height: 44)

            if let start = restStart, index < all.count {
                restView(since: start, next: all[index], newBlock: index > 0 && all[index - 1].blockIndex != all[index].blockIndex)
            } else if index < all.count {
                let step = all[index]
                ScrollView { VStack(spacing: 20) { content(step: step, all: all) }.padding(.horizontal, Space.margin) }.padding(.horizontal, -Space.margin).scrollIndicators(.hidden)
                Button(step.circuit != nil ? "Complete round \(step.number)" : "Complete set \(step.number)") { complete(step: step, all: all) }
                    .buttonStyle(PrimaryButton())
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
            Text("\(c) · ROUND \(step.number) OF \(step.total)").font(.system(size: 12, weight: .semibold)).tracking(0.7).foregroundStyle(Color.textSecondary).frame(maxWidth: .infinity, alignment: .leading)
        }
        VStack(alignment: .leading, spacing: 4) {
            Text(ex.name).font(.system(size: 28, weight: .bold))
            Text("Currently using \(fmt(ex.weightKg)) kg · \(ex.targetSets) × \(ex.targetReps)").font(.system(size: 15)).foregroundStyle(Color.textSecondary)
        }.frame(maxWidth: .infinity, alignment: .leading)

        ExerciseArt(exercise: ex, portrait: true, radius: 0).padding(.horizontal, -Space.margin)
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

        if !ex.tips.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("How to do it").font(.system(size: 20, weight: .bold)).foregroundStyle(Color.textPrimary)
                TipsList(tips: ex.tips)
            }.frame(maxWidth: .infinity, alignment: .leading).padding(.top, 8)
        }
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
        let s = session ?? { let n = WorkoutSession(planName: planName); ctx.insert(n); session = n; return n }()
        let log = SetLog(exerciseName: step.exercise.name, weightKg: step.exercise.weightKg, reps: reps, setNumber: step.number, circuitName: step.circuit)
        ctx.insert(log); s.sets.append(log)
        done[index] = reps
        step.exercise.targetReps = reps          // remembered as the starting reps next time
        try? ctx.save()
        index += 1
        if index < all.count {
            reps = all[index].exercise.targetReps
            let next = all[index]
            // Finished a round of a circuit and something follows (another round or the next circuit/exercise): start the rest stopwatch.
            if step.circuit != nil, next.blockIndex != step.blockIndex || next.number != step.number { restStart = .now }
        }
    }

    /// Stopwatch shown between circuit rounds so you can see how long you are resting. Not stored anywhere.
    private func restView(since start: Date, next: WorkoutStep, newBlock: Bool) -> some View {
        VStack(spacing: 0) {
            Spacer()
            Text("REST").font(.system(size: 12, weight: .semibold)).tracking(0.7).foregroundStyle(Color.textSecondary)
            TimelineView(.periodic(from: start, by: 1)) { ctx in
                let secs = max(0, Int(ctx.date.timeIntervalSince(start)))
                Text(String(format: "%d:%02d", secs / 60, secs % 60))
                    .font(.system(size: 88, weight: .bold)).monospacedDigit().padding(.vertical, 8)
            }
            Text(newBlock ? (next.circuit != nil ? "Next: \(next.circuit!)" : "Next: \(next.exercise.name)")
                          : "\(next.circuit ?? "Circuit") · next: round \(next.number) of \(next.total)")
                .font(.system(size: 15)).foregroundStyle(Color.textSecondary)
            Spacer()
            Button(newBlock ? (next.circuit != nil ? "Start \(next.circuit!)" : "Start next exercise") : "Start round \(next.number)") { restStart = nil }.buttonStyle(PrimaryButton())
        }
    }
}
