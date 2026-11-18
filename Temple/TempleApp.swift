import SwiftUI
import SwiftData

@main
struct TempleApp: App {
    var body: some Scene {
        WindowGroup { RootView().preferredColorScheme(.dark) }
            .modelContainer(for: [Exercise.self, Plan.self, PlanBlock.self, WorkoutSession.self, SetLog.self, MealEntry.self, Targets.self])
    }
}

struct RootView: View {
    var body: some View {
        TabView {
            Tab("Exercises", systemImage: "dumbbell") { Text("Exercises").foregroundStyle(Color.textPrimary) }
            Tab("Plans", systemImage: "list.bullet") { Text("Plans").foregroundStyle(Color.textPrimary) }
            Tab("Nutrition", systemImage: "circle.circle") { Text("Nutrition").foregroundStyle(Color.textPrimary) }
            Tab("Calendar", systemImage: "calendar") { Text("Calendar").foregroundStyle(Color.textPrimary) }
        }
        .tint(Color.yolk)
        .background(Color.bg)
    }
}
