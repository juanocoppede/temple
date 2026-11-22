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
                VStack(spacing: 20) {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass").foregroundStyle(Color.textSecondary)
                        TextField("Search \(exercises.count) exercises", text: $search)
                            .textInputAutocapitalization(.never).autocorrectionDisabled()
                        if !search.isEmpty {
                            Button { search = "" } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(Color.textSecondary) }.buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16).frame(height: 44)
                    .modifier(GlassCapsule())
                    .padding(.horizontal, Space.margin)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(groups, id: \.self) { g in
                                Button { group = g } label: { Chip(text: g, selected: g == group) }.buttonStyle(.plain)
                            }
                        }.padding(.horizontal, Space.margin)
                    }

                    VStack(spacing: 0) {
                        ForEach(Array(filtered.enumerated()), id: \.element.persistentModelID) { i, ex in
                            NavigationLink { ExerciseDetailView(exercise: ex) } label: { ExerciseRow(exercise: ex) }.buttonStyle(.plain)
                            if i < filtered.count - 1 { Divider().overlay(Color.white.opacity(0.08)).padding(.leading, 70) }
                        }
                    }
                    .padding(.horizontal, Space.margin)
                }
                .padding(.top, 8)
            }
            .scrollDismissesKeyboard(.immediately)
            .contentMargins(.bottom, Space.tabBarClearance, for: .scrollContent)
            .background(Color.bg)
            .navigationTitle("Exercises")
        }
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    var body: some View {
        HStack(spacing: 14) {
            ExerciseArt(exercise: exercise, side: 56)
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
        .padding(.vertical, 12)
    }
}
