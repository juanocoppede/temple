import Foundation
import SwiftData

enum MealSlot: String, Codable, CaseIterable { case breakfast = "Breakfast", lunch = "Lunch", merienda = "Merienda", dinner = "Dinner", snacks = "Snacks" }

@Model final class Exercise {
    var name: String
    var muscleGroup: String
    var equipment: String
    var weightKg: Double          // one current weight per exercise
    var targetSets: Int
    var targetReps: Int
    var isTimed: Bool
    var illustration: String?
    init(name: String, muscleGroup: String, equipment: String, weightKg: Double = 0, targetSets: Int = 3, targetReps: Int = 10, isTimed: Bool = false, illustration: String? = nil) {
        self.name = name; self.muscleGroup = muscleGroup; self.equipment = equipment; self.weightKg = weightKg
        self.targetSets = targetSets; self.targetReps = targetReps; self.isTimed = isTimed; self.illustration = illustration
    }
}

@Model final class Plan {
    var name: String
    @Relationship(deleteRule: .cascade) var blocks: [PlanBlock] = []
    init(name: String) { self.name = name }
}

/// A block is either a single exercise or a circuit (ordered exercises, always 3 rounds).
@Model final class PlanBlock {
    var order: Int
    var isCircuit: Bool
    var circuitName: String?
    var exerciseNames: [String] = []   // ordered; names are unique
    init(order: Int, isCircuit: Bool, circuitName: String? = nil, exerciseNames: [String]) { self.order = order; self.isCircuit = isCircuit; self.circuitName = circuitName; self.exerciseNames = exerciseNames }
    static let circuitRounds = 3
}

/// Sessions store snapshot copies so editing a plan never rewrites history.
@Model final class WorkoutSession {
    var date: Date
    var planName: String?
    @Relationship(deleteRule: .cascade) var sets: [SetLog] = []
    init(date: Date = .now, planName: String? = nil) { self.date = date; self.planName = planName }
}

@Model final class SetLog {
    var exerciseName: String      // snapshot
    var weightKg: Double          // snapshot
    var reps: Int
    var setNumber: Int
    var circuitName: String?
    var date: Date
    init(exerciseName: String, weightKg: Double, reps: Int, setNumber: Int, circuitName: String? = nil, date: Date = .now) {
        self.exerciseName = exerciseName; self.weightKg = weightKg; self.reps = reps; self.setNumber = setNumber; self.circuitName = circuitName; self.date = date
    }
}

@Model final class MealEntry {
    var date: Date
    var slotRaw: String
    var name: String
    var grams: Double
    var kcal: Double
    var proteinG: Double
    var slot: MealSlot { get { MealSlot(rawValue: slotRaw) ?? .snacks } set { slotRaw = newValue.rawValue } }
    init(date: Date = .now, slot: MealSlot, name: String, grams: Double, kcal: Double, proteinG: Double) {
        self.date = date; self.slotRaw = slot.rawValue; self.name = name; self.grams = grams; self.kcal = kcal; self.proteinG = proteinG
    }
}

@Model final class Targets {
    var kcal: Double
    var proteinG: Double
    init(kcal: Double = 2400, proteinG: Double = 150) { self.kcal = kcal; self.proteinG = proteinG }
}
