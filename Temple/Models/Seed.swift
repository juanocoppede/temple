import Foundation
import SwiftData

/// Keeps the preloaded library in sync. Existing exercises keep the user's weights and reps.
enum Seed {
    private static let cleanupKey = "seedCleanup2"

    static func run(_ ctx: ModelContext) {
        let d = UserDefaults.standard
        if !d.bool(forKey: cleanupKey) {
            // One-time reset: no preloaded plans, and every exercise starts from zero.
            try? ctx.delete(model: Plan.self)
            try? ctx.delete(model: PlanBlock.self)
            try? ctx.delete(model: Exercise.self)
            d.set(true, forKey: cleanupKey)
        }
        let existing = (try? ctx.fetch(FetchDescriptor<Exercise>())) ?? []
        let byName = Dictionary(existing.map { ($0.name, $0) }, uniquingKeysWith: { a, _ in a })
        for e in Library.all {
            if let ex = byName[e.name] {
                ex.muscleGroup = e.group; ex.equipment = e.equipment; ex.isTimed = e.timed; ex.illustration = e.art; ex.tips = e.tips
            } else {
                ctx.insert(Exercise(name: e.name, muscleGroup: e.group, equipment: e.equipment, isTimed: e.timed, illustration: e.art, tips: e.tips))
            }
        }
        // Remove stale library exercises (old names) that have no history.
        let names = Set(Library.all.map(\.name))
        let logged = Set(((try? ctx.fetch(FetchDescriptor<SetLog>())) ?? []).map(\.exerciseName))
        for ex in existing where !names.contains(ex.name) && !logged.contains(ex.name) { ctx.delete(ex) }
        if ((try? ctx.fetchCount(FetchDescriptor<Targets>())) ?? 0) == 0 { ctx.insert(Targets()) }
        try? ctx.save()
    }
}
