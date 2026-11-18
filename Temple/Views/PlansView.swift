import SwiftUI
import SwiftData

struct PlansView: View {
    @Query(sort: \Plan.name) private var plans: [Plan]
    @State private var running: Plan?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(Array(plans.enumerated()), id: \.element.persistentModelID) { i, plan in
                        let count = plan.blocks.reduce(0) { $0 + $1.exerciseNames.count }
                        let circuits = plan.blocks.filter(\.isCircuit).count
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(plan.name).font(.system(size: 17, weight: .semibold))
                                Text("\(count) exercises" + (circuits > 0 ? " · \(circuits) circuit\(circuits == 1 ? "" : "s")" : ""))
                                    .font(.system(size: 13)).foregroundStyle(Color.textSecondary)
                            }
                            Spacer()
                            Button("Start") { running = plan }
                                .font(.system(size: 15, weight: .semibold)).foregroundStyle(Color.yolkInk)
                                .padding(.horizontal, 20).frame(height: 40)
                                .background(Color.yolk, in: RoundedRectangle(cornerRadius: Radius.control))
                        }
                        .foregroundStyle(Color.textPrimary).card()
                        .id(i)
                    }
                }.padding(Space.margin)
            }
            .background(Color.bg)
            .navigationTitle("Plans")
        }
        .fullScreenCover(item: $running) { plan in WorkoutView(plan: plan) }
    }
}
