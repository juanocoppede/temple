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
        case .exercises: return "figure.strengthtraining.traditional"
        case .plans: return "square.grid.2x2"
        case .nutrition: return ""   // custom trending-up bars icon
        case .calendar: return "calendar"
        }
    }
}

struct RootView: View {
    @Environment(\.modelContext) private var ctx
    @State private var tab: AppTab = .exercises

    var body: some View {
        ZStack {
            ZStack {
                ExercisesView().opacity(tab == .exercises ? 1 : 0).allowsHitTesting(tab == .exercises)
                PlansView().opacity(tab == .plans ? 1 : 0).allowsHitTesting(tab == .plans)
                NutritionView().opacity(tab == .nutrition ? 1 : 0).allowsHitTesting(tab == .nutrition)
                CalendarView().opacity(tab == .calendar ? 1 : 0).allowsHitTesting(tab == .calendar)
            }
        }
        // The bar is a bottom safe-area inset, so every list/scroll view stops above it automatically.
        // The 28 pt of clear space above the bar is part of the inset: lists get room to breathe at the end.
        .safeAreaInset(edge: .bottom, spacing: 0) {
            FloatingTabBar(selection: $tab).padding(.top, 28)
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
                        Group {
                            if t == .nutrition { TrendBarsIcon().stroke(style: StrokeStyle(lineWidth: 1.75, lineCap: .round, lineJoin: .round)).frame(width: 24, height: 24) }
                            else { Image(systemName: t.icon).font(.system(size: 22, weight: .regular)) }
                        }.frame(height: 24)
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
        .padding(.bottom, 6)             // sits just above the iPhone's home-indicator zone
    }
}

/// Three ascending bars with a small trend arrow.
struct TrendBarsIcon: Shape {
    func path(in r: CGRect) -> Path {
        let u = r.width / 24
        func P(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: r.minX + x * u, y: r.minY + y * u) }
        var p = Path()
        p.move(to: P(5, 20)); p.addLine(to: P(5, 14))
        p.move(to: P(11, 20)); p.addLine(to: P(11, 10))
        p.move(to: P(17, 20)); p.addLine(to: P(17, 12))
        p.move(to: P(3.5, 8)); p.addLine(to: P(9, 4.5)); p.addLine(to: P(13, 7)); p.addLine(to: P(20, 3))
        p.move(to: P(16, 3)); p.addLine(to: P(20, 3)); p.addLine(to: P(20, 7))
        return p
    }
}
