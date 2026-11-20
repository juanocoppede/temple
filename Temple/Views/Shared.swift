import SwiftUI
import UIKit

/// Illustration for an exercise (falls back to a quiet icon when there is none yet).
struct ExerciseArt: View {
    let exercise: Exercise
    var height: CGFloat? = nil
    var side: CGFloat? = nil
    var radius: CGFloat = 14
    var body: some View {
        Group {
            if let n = exercise.illustration, UIImage(named: n) != nil {
                Image(n).resizable().scaledToFill().scaleEffect(height == nil ? 1.1 : 1)
            } else {
                Color.raised.overlay(Image(systemName: "figure.strengthtraining.traditional").foregroundStyle(Color.textSecondary))
            }
        }
        .frame(width: side, height: side ?? height)
        .frame(maxWidth: side == nil ? .infinity : nil)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: radius))
    }
}

struct TipsList: View {
    let tips: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(Array(tips.enumerated()), id: \.offset) { i, t in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(i + 1)").font(.system(size: 13, weight: .bold)).foregroundStyle(Color.yolkInk)
                        .frame(width: 22, height: 22).background(Color.yolk, in: Circle())
                    Text(t).font(.system(size: 15)).lineSpacing(3).foregroundStyle(Color.textPrimary)
                }
            }
        }
    }
}

/// "Cómo hacerlo" modal: frosted glass over a dimmed scrim.
struct TipsSheet: View {
    let exercise: Exercise
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(exercise.name).font(.system(size: 28, weight: .bold))
                Text("Cómo hacerlo").font(.system(size: 12, weight: .semibold)).tracking(0.7).textCase(.uppercase).foregroundStyle(Color.yolk)
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
