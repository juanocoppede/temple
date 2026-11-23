import SwiftUI
import CoreMotion

/// Daily steps for the last 7 days, read from the iPhone's motion coprocessor (no HealthKit needed).
@MainActor final class StepsModel: ObservableObject {
    @Published var steps: [Int?] = Array(repeating: nil, count: 7)
    @Published var unavailable = false
    let days: [Date]
    private let pedometer = CMPedometer()

    init() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        days = (0..<7).reversed().compactMap { cal.date(byAdding: .day, value: -$0, to: today) }
    }

    func load() {
        guard CMPedometer.isStepCountingAvailable() else { unavailable = true; return }
        let cal = Calendar.current
        for (i, d) in days.enumerated() {
            let end = min(cal.date(byAdding: .day, value: 1, to: d) ?? d, .now)
            pedometer.queryPedometerData(from: d, to: end) { data, err in
                let n = data?.numberOfSteps.intValue
                DispatchQueue.main.async {
                    if err != nil && n == nil { self.unavailable = true }
                    self.steps[i] = n
                }
            }
        }
    }
}

struct StepsCard: View {
    @StateObject private var model = StepsModel()
    @Environment(\.scenePhase) private var phase
    private let barArea: CGFloat = 110

    private let goal = 10_000.0
    private var scale: Double { max(goal, Double(model.steps.compactMap { $0 }.max() ?? 0)) }
    private func label(_ v: Int?) -> String {
        guard let v, v > 0 else { return "–" }
        return v >= 1000 ? String(format: "%.1fk", Double(v) / 1000) : "\(v)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Steps").font(.system(size: 20, weight: .bold)).foregroundStyle(Color.textPrimary)
            if model.unavailable {
                Text("Steps aren't available. Allow Motion & Fitness for Temple in Settings → Privacy & Security.")
                    .font(.system(size: 13)).foregroundStyle(Color.textSecondary)
            } else {
                if let today = model.steps.last ?? nil {
                    Text(today.formatted()).font(.system(size: 34, weight: .bold)).monospacedDigit()
                    + Text("  today").font(.system(size: 15)).foregroundColor(Color.textSecondary)
                }
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(model.steps.indices, id: \.self) { i in
                        let v = model.steps[i] ?? 0
                        let isToday = Calendar.current.isDateInToday(model.days[i])
                        VStack(spacing: 8) {
                            Text(label(model.steps[i])).font(.system(size: 11)).foregroundStyle(Color.textSecondary).monospacedDigit().lineLimit(1).minimumScaleFactor(0.7)
                            ZStack(alignment: .bottom) {
                                Color.clear.frame(height: barArea)
                                Capsule().fill(v > 0 ? Color.yolk : Color.raised)
                                    .frame(height: v > 0 ? max(barArea * CGFloat(Double(v) / scale), 30) : 30)
                                    .padding(.horizontal, 4)
                                GoalLine().stroke(Color.white.opacity(0.6), lineWidth: 1)
                                    .frame(height: 1).offset(y: -barArea * CGFloat(goal / scale))
                            }
                            Text(model.days[i].formatted(.dateTime.weekday(.abbreviated))).font(.system(size: 11, weight: isToday ? .bold : .medium))
                                .foregroundStyle(isToday ? Color.yolk : Color.textSecondary).lineLimit(1).minimumScaleFactor(0.7)
                        }.frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(Space.inCard).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.card, in: RoundedRectangle(cornerRadius: Radius.card))
        .onAppear { model.load() }
        .onChange(of: phase) { _, p in if p == .active { model.load() } }
    }
}
