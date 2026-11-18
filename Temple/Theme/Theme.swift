import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255, blue: Double(hex & 0xFF) / 255)
    }
    static let bg = Color(hex: 0x000000)
    static let card = Color(hex: 0x1C1C1E)
    static let raised = Color(hex: 0x2C2C2E)
    static let textPrimary = Color(hex: 0xF5F5F7)
    static let textSecondary = Color(hex: 0x8E8E93)
    static let yolk = Color(hex: 0xF5C03A)
    static let yolkSoft = Color(hex: 0xF5C03A).opacity(0.14)
    static let yolkInk = Color(hex: 0x1A1400)
    static let destructive = Color(hex: 0xFF453A)
}

enum Radius { static let control: CGFloat = 12, cta: CGFloat = 16, card: CGFloat = 20, sheet: CGFloat = 28 }
enum Space { static let margin: CGFloat = 20, inCard: CGFloat = 16 }

struct PrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(Color.yolkInk)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(Color.yolk, in: RoundedRectangle(cornerRadius: Radius.cta))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}
