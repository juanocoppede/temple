import SwiftUI
import UIKit

/// Photo for an exercise. Square (1:1) by default; `portrait` uses the 3:4 version at full width.
struct ExerciseArt: View {
    let exercise: Exercise
    var side: CGFloat? = nil        // fixed square size; nil = flexible width
    var portrait = false
    var radius: CGFloat = 14

    @ViewBuilder private var image: some View {
        if let n = exercise.illustration, let img = UIImage(named: portrait ? n + "-34" : n) {
            Image(uiImage: img).resizable().scaledToFill()
        } else {
            Color.raised.overlay(Image(systemName: "figure.strengthtraining.traditional").foregroundStyle(Color.textSecondary))
        }
    }
    var body: some View {
        Group {
            if let side {
                Color.clear.frame(width: side, height: side)
            } else {
                Color.clear.frame(maxWidth: .infinity).aspectRatio(1, contentMode: .fit)
            }
        }
        .overlay(image)
        .background(Color.card)
        .clipShape(RoundedRectangle(cornerRadius: radius))
    }
}

struct TipsList: View {
    let tips: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(Array(tips.enumerated()), id: \.offset) { i, t in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(i + 1)").font(.system(size: 13, weight: .bold)).foregroundStyle(Color.textPrimary)
                        .frame(width: 22, height: 22).background(Color.raised, in: Circle())
                    Text(t).font(.system(size: 15)).lineSpacing(3).foregroundStyle(Color.textPrimary)
                }
            }
        }
    }
}

/// "How to do it" modal: frosted glass over a dimmed scrim.
struct TipsSheet: View {
    let exercise: Exercise
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(exercise.name).font(.system(size: 28, weight: .bold))
                Text("How to do it").font(.system(size: 12, weight: .semibold)).tracking(0.7).textCase(.uppercase).foregroundStyle(Color.textSecondary)
                TipsList(tips: exercise.tips)
            }
            .padding(Space.margin).frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(Color.textPrimary)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(.ultraThinMaterial)
        .presentationCornerRadius(Radius.sheet)
    }
}
