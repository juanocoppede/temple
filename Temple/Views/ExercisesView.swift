import SwiftUI
import SwiftData

struct ExercisesView: View {
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @State private var search = ""
    @State private var group = "All"

    private var groups: [String] { ["All"] + Array(Set(exercises.map(\.muscleGroup))).sorted() }
    private var filtered: [Exercise] {
        exercises.filter { (group == "All" || $0.muscleGroup == group) && (search.isEmpty || $0.name.localizedCaseInsensitiveContains(search)) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section {
                        VStack(spacing: 0) {
                            ForEach(Array(filtered.enumerated()), id: \.element.persistentModelID) { i, ex in
                                ExerciseRow(exercise: ex)
                                if i < filtered.count - 1 { Divider().overlay(Color.white.opacity(0.08)).padding(.leading, 86) }
                            }
                        }
                        .background(Color.card, in: RoundedRectangle(cornerRadius: Radius.card))
                        .padding(.horizontal, Space.margin).padding(.top, 8)
                    } header: {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(groups, id: \.self) { g in
                                    Button { group = g } label: { Chip(text: g, selected: g == group) }.buttonStyle(.plain)
                                }
                            }.padding(.horizontal, Space.margin).padding(.vertical, 8)
                        }
                        .background(Color.bg)
                    }
                }
            }
            .background(Color.bg)
            .navigationTitle("Exercises")
            .searchable(text: $search, prompt: "Search \(exercises.count) exercises")
        }
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 14).fill(Color.raised).frame(width: 56, height: 56)
                .overlay(Image(systemName: "figure.strengthtraining.traditional").foregroundStyle(Color.textSecondary))
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name).font(.system(size: 17, weight: .semibold)).lineLimit(1)
                Text("\(exercise.muscleGroup) · \(exercise.equipment)").font(.system(size: 13)).foregroundStyle(Color.textSecondary)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 0) {
                Text(exercise.isTimed ? "\(exercise.targetReps) s" : (exercise.weightKg == 0 ? "+0 kg" : "\(fmt(exercise.weightKg)) kg"))
                    .font(.system(size: 17, weight: .semibold)).monospacedDigit()
                Text(exercise.isTimed ? "\(exercise.targetSets) sets" : "\(exercise.targetSets) × \(exercise.targetReps)")
                    .font(.system(size: 12)).foregroundStyle(Color.textSecondary).monospacedDigit()
            }
        }
        .foregroundStyle(Color.textPrimary)
        .padding(Space.inCard)
    }
}
