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
    case home = "Home", exercises = "Exercises", plans = "Plans", nutrition = "Nutrition", calendar = "Calendar"
    var icon: String {
        switch self {
        case .home: return "house"
        case .exercises: return "figure.strengthtraining.traditional"
        case .plans: return "square.grid.2x2"
        case .nutrition: return ""   // custom trending-up bars icon
        case .calendar: return "calendar"
        }
    }
}

struct RootView: View {
    @Environment(\.modelContext) private var ctx
    @Environment(\.scenePhase) private var phase
    @State private var tab: AppTab = .home
    @State private var resets: [AppTab: Int] = [:]      // bumping a tab's counter rebuilds it, returning to its root screen

    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                HomeView().id(resets[.home, default: 0]).opacity(tab == .home ? 1 : 0).allowsHitTesting(tab == .home).zIndex(tab == .home ? 1 : 0)
                ExercisesView().id(resets[.exercises, default: 0]).opacity(tab == .exercises ? 1 : 0).allowsHitTesting(tab == .exercises).zIndex(tab == .exercises ? 1 : 0)
                PlansView().id(resets[.plans, default: 0]).opacity(tab == .plans ? 1 : 0).allowsHitTesting(tab == .plans).zIndex(tab == .plans ? 1 : 0)
                NutritionView().id(resets[.nutrition, default: 0]).opacity(tab == .nutrition ? 1 : 0).allowsHitTesting(tab == .nutrition).zIndex(tab == .nutrition ? 1 : 0)
                CalendarView().id(resets[.calendar, default: 0]).opacity(tab == .calendar ? 1 : 0).allowsHitTesting(tab == .calendar).zIndex(tab == .calendar ? 1 : 0)
            }
            FloatingTabBar(selection: $tab) { resets[$0, default: 0] += 1 }
        }
        .background(Color.bg.ignoresSafeArea())
        .onAppear { Seed.run(ctx); Backup.runDailyIfNeeded(ctx) }
        .onChange(of: phase) { _, p in if p == .active { Backup.runDailyIfNeeded(ctx) } }
    }
}

/// Floating liquid-glass tab bar: 20 pt from the sides and bottom, 28 pt of air above and below the content.
struct FloatingTabBar: View {
    @Binding var selection: AppTab
    var onTap: (AppTab) -> Void = { _ in }
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { t in
                Button { onTap(t); selection = t } label: {
                    VStack(spacing: 4) {
                        Group {
                            if t == .nutrition { TrendBarsIcon().stroke(style: StrokeStyle(lineWidth: 1.75, lineCap: .round, lineJoin: .round)).frame(width: 24, height: 24) }
                            else { Image(systemName: t.icon).font(.system(size: 22, weight: .regular)) }
                        }.frame(height: 24)
                        Text(t.rawValue).font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(selection == t ? Color.yolk : Color.textSecondary)
                    .padding(.vertical, 28)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }.buttonStyle(.plain)
            }
        }
        .modifier(GlassBar())
        .shadow(color: .black.opacity(0.35), radius: 12, y: 8)
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

/// Liquid Glass card (rounded rectangle) with the standard in-card padding.
struct GlassCard: ViewModifier {
    @ViewBuilder func body(content: Content) -> some View {
        let padded = content.padding(Space.inCard).frame(maxWidth: .infinity, alignment: .leading)
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            padded.glassEffect(.regular, in: RoundedRectangle(cornerRadius: Radius.card))
        } else { fallback(padded) }
        #else
        fallback(padded)
        #endif
    }
    private func fallback(_ content: some View) -> some View {
        content.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radius.card))
            .overlay(RoundedRectangle(cornerRadius: Radius.card).stroke(Color.white.opacity(0.12), lineWidth: 1))
    }
}
extension View { func glassCard() -> some View { modifier(GlassCard()) } }

/// Liquid Glass capsule for chips and fields (material fallback before iOS 26).
struct GlassCapsule: ViewModifier {
    var tint: Color? = nil
    @ViewBuilder func body(content: Content) -> some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            content.glassEffect(tint == nil ? .regular : .regular.tint(tint!), in: Capsule())
        } else { fallback(content) }
        #else
        fallback(content)
        #endif
    }
    private func fallback(_ content: Content) -> some View {
        content.background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.16), lineWidth: 1))
    }
}

/// Real Liquid Glass on iOS 26+ (when built with the iOS 26 SDK); a translucent material on older systems.
struct GlassBar: ViewModifier {
    @ViewBuilder func body(content: Content) -> some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular, in: RoundedRectangle(cornerRadius: 28))
        } else { fallback(content) }
        #else
        fallback(content)
        #endif
    }
    private func fallback(_ content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.white.opacity(0.16), lineWidth: 1))
    }
}
