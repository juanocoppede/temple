import Foundation
import SwiftData

/// Placeholder starter data so the app is usable on first launch. Everything is editable later.
enum Seed {
    static func run(_ ctx: ModelContext) {
        let n = (try? ctx.fetchCount(FetchDescriptor<Exercise>())) ?? 0
        guard n == 0 else { return }
        let list: [Exercise] = [
            Exercise(name: "Press militar con mancuernas", muscleGroup: "Shoulders", equipment: "Dumbbells", weightKg: 14, targetSets: 3, targetReps: 10),
            Exercise(name: "Elevaciones laterales", muscleGroup: "Shoulders", equipment: "Dumbbells", weightKg: 8, targetSets: 3, targetReps: 12),
            Exercise(name: "Fondos en paralelas", muscleGroup: "Chest", equipment: "Parallel bars", weightKg: 0, targetSets: 3, targetReps: 12),
            Exercise(name: "Press de banca plano", muscleGroup: "Chest", equipment: "Dumbbells, bench", weightKg: 20, targetSets: 4, targetReps: 8),
            Exercise(name: "Dominadas supinas", muscleGroup: "Back", equipment: "Pull-up bar", weightKg: 0, targetSets: 4, targetReps: 8),
            Exercise(name: "Curl martillo de pie", muscleGroup: "Arms", equipment: "Dumbbells", weightKg: 10, targetSets: 3, targetReps: 12),
            Exercise(name: "Sentadilla búlgara", muscleGroup: "Legs", equipment: "Bench, dumbbells", weightKg: 12, targetSets: 3, targetReps: 10),
            Exercise(name: "Hollow body hold", muscleGroup: "Core", equipment: "None", weightKg: 0, targetSets: 3, targetReps: 30, isTimed: true),
        ]
        list.forEach(ctx.insert)
        let push = Plan(name: "Push day")
        push.blocks = [
            PlanBlock(order: 0, isCircuit: true, circuitName: "Circuit A", exerciseNames: ["Press militar con mancuernas", "Elevaciones laterales"]),
            PlanBlock(order: 1, isCircuit: false, exerciseNames: ["Fondos en paralelas"]),
            PlanBlock(order: 2, isCircuit: false, exerciseNames: ["Press de banca plano"]),
        ]
        let pull = Plan(name: "Pull day")
        pull.blocks = [PlanBlock(order: 0, isCircuit: false, exerciseNames: ["Dominadas supinas"]), PlanBlock(order: 1, isCircuit: false, exerciseNames: ["Curl martillo de pie"])]
        let legs = Plan(name: "Legs and core")
        legs.blocks = [PlanBlock(order: 0, isCircuit: false, exerciseNames: ["Sentadilla búlgara"]), PlanBlock(order: 1, isCircuit: false, exerciseNames: ["Hollow body hold"])]
        [push, pull, legs].forEach(ctx.insert)
        ctx.insert(Targets())
        try? ctx.save()
    }
}
