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
    @Environment(\.modelContext) private var ctx
    var body: some View {
        TabView {
            Tab("Exercises", systemImage: "dumbbell") { ExercisesView() }
            Tab("Plans", systemImage: "list.bullet") { PlansView() }
            Tab("Nutrition", systemImage: "circle.circle") { Text("Nutrition").foregroundStyle(Color.textPrimary) }
            Tab("Calendar", systemImage: "calendar") { Text("Calendar").foregroundStyle(Color.textPrimary) }
        }
        .tint(Color.yolk)
        .background(Color.bg)
        .onAppear { Seed.run(ctx) }
    }
}
