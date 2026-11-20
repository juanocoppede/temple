import SwiftUI
import SwiftData

@main
struct TempleApp: App {
    var body: some Scene {
        WindowGroup { RootView().preferredColorScheme(.dark) }
            .modelContainer(for: [Exercise.self, Plan.self, PlanBlock.self, WorkoutSession.self, SetLog.self, MealEntry.self, Targets.self])
    }
}

enum AppTab: String, CaseIterable {
    case exercises = "Exercises", plans = "Plans", nutrition = "Nutrition", calendar = "Calendar"
    var icon: String {
        switch self {
        case .exercises: return "dumbbell"
        case .plans: return "list.bullet"
        case .nutrition: return "circle.circle"
        case .calendar: return "calendar"
        }
    }
}

struct RootView: View {
    @Environment(\.modelContext) private var ctx
    @State private var tab: AppTab = .exercises

    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                ExercisesView().opacity(tab == .exercises ? 1 : 0).allowsHitTesting(tab == .exercises)
                PlansView().opacity(tab == .plans ? 1 : 0).allowsHitTesting(tab == .plans)
                NutritionView().opacity(tab == .nutrition ? 1 : 0).allowsHitTesting(tab == .nutrition)
                CalendarView().opacity(tab == .calendar ? 1 : 0).allowsHitTesting(tab == .calendar)
            }
            .safeAreaPadding(.bottom, 120)       // lists end well above the floating bar
            FloatingTabBar(selection: $tab)
        }
        .background(Color.bg.ignoresSafeArea())
        .onAppear { Seed.run(ctx) }
    }
}

/// Floating liquid-glass tab bar: 20 pt from the sides and bottom, 28 pt of air above and below the content.
struct FloatingTabBar: View {
    @Binding var selection: AppTab
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { t in
                Button { selection = t } label: {
                    VStack(spacing: 4) {
                        Image(systemName: t.icon).font(.system(size: 22, weight: .regular)).frame(height: 24)
                        Text(t.rawValue).font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(selection == t ? Color.yolk : Color.textSecondary)
                    .frame(maxWidth: .infinity)
                }.buttonStyle(.plain)
            }
        }
        .padding(.vertical, 28)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.white.opacity(0.16), lineWidth: 1))
        .shadow(color: .black.opacity(0.5), radius: 12, y: 8)
        .padding(.horizontal, Space.margin)
        .padding(.bottom, 20)
        .ignoresSafeArea(edges: .bottom)
    }
}
