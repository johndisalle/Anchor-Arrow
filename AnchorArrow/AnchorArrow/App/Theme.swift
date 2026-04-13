import SwiftUI

// MARK: - Adaptive Color Helper
/// Creates a Color that resolves differently in light vs dark mode
private func adaptive(light: UIColor, dark: UIColor) -> Color {
    Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark ? dark : light
    })
}

// MARK: - Anchor & Arrow Theme
/// Masculine color palette: deep steel, burnt amber, warm gold, stone, dark iron
/// Mirrors AnchorBloom's design system adapted for men
struct AATheme {
    // MARK: - Brand Colors (same in both modes)
    static let steel = Color(red: 0.22, green: 0.30, blue: 0.42)              // #384D6B — deep steel blue
    static let steelDark = Color(red: 0.15, green: 0.21, blue: 0.32)          // #263652 — darker steel
    static let amber = Color(red: 0.76, green: 0.52, blue: 0.30)              // #C2854D — burnt amber
    static let amberDark = Color(red: 0.62, green: 0.40, blue: 0.22)          // #9E6638 — darker amber
    static let warmGold = Color(red: 0.85, green: 0.75, blue: 0.55)           // #D9BF8C — warm gold
    static let warmGoldLight = adaptive(
        light: UIColor(red: 0.93, green: 0.87, blue: 0.73, alpha: 1),         // #EDDEBA
        dark: UIColor(red: 0.55, green: 0.48, blue: 0.30, alpha: 1)           // darker gold
    )

    // MARK: - Surface Colors (adaptive)
    static let stone = adaptive(
        light: UIColor(red: 0.96, green: 0.94, blue: 0.90, alpha: 1),         // #F5F0E6 — warm stone
        dark: UIColor(red: 0.09, green: 0.09, blue: 0.11, alpha: 1)           // #17171C — deep charcoal
    )
    static let darkIron = Color(red: 0.12, green: 0.14, blue: 0.20)           // #1F2433 — dark iron
    static let parchment = adaptive(
        light: UIColor(red: 0.99, green: 0.97, blue: 0.94, alpha: 1),         // #FCF8F0 — warm parchment
        dark: UIColor(red: 0.18, green: 0.18, blue: 0.21, alpha: 1)           // #2E2E36 — elevated dark card
    )

    // MARK: - Semantic Colors (adaptive)
    static let primaryText = adaptive(
        light: UIColor(red: 0.12, green: 0.14, blue: 0.20, alpha: 1),         // darkIron
        dark: UIColor(red: 0.93, green: 0.91, blue: 0.87, alpha: 1)           // warm off-white
    )
    static let secondaryText = adaptive(
        light: UIColor(red: 0.42, green: 0.44, blue: 0.50, alpha: 1),         // #6B7080
        dark: UIColor(red: 0.58, green: 0.56, blue: 0.53, alpha: 1)           // muted warm gray
    )
    static let background = stone
    static let cardBackground = parchment
    static let accent = steel
    static let accentSecondary = amber
    static let accentTertiary = warmGold
    static let destructive = Color(red: 0.78, green: 0.32, blue: 0.32)        // #C75252
    static let success = Color(red: 0.35, green: 0.60, blue: 0.40)            // #599966
    static let warning = Color(red: 0.85, green: 0.58, blue: 0.25)            // #D99440

    // MARK: - Gradients
    static let morningGradient = LinearGradient(
        colors: [warmGoldLight, stone, parchment],
        startPoint: .top,
        endPoint: .bottom
    )

    static let eveningGradient = LinearGradient(
        colors: [
            Color(red: 0.15, green: 0.18, blue: 0.28),
            Color(red: 0.22, green: 0.20, blue: 0.30),
            darkIron
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cardGradient = LinearGradient(
        colors: [parchment, stone.opacity(0.5)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let arrowGradient = LinearGradient(
        colors: [amber.opacity(0.3), steel.opacity(0.2)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let premiumGradient = LinearGradient(
        colors: [warmGold, Color(red: 0.78, green: 0.65, blue: 0.40)],
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - Typography
    static let titleFont = Font.system(.largeTitle, design: .serif, weight: .bold)
    static let headlineFont = Font.system(.title2, design: .serif, weight: .semibold)
    static let subheadlineFont = Font.system(.headline, design: .serif, weight: .medium)
    static let bodyFont = Font.system(.body, design: .default)
    static let captionFont = Font.system(.caption, design: .default)
    static let scriptureFont = Font.system(.body, design: .serif).italic()

    // MARK: - Spacing
    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 16
    static let paddingLarge: CGFloat = 24
    static let paddingXLarge: CGFloat = 32
    static let cornerRadius: CGFloat = 16
    static let cornerRadiusSmall: CGFloat = 10

    // MARK: - Shadows
    static let cardShadow = Color.black.opacity(0.08)
    static let cardShadowRadius: CGFloat = 8
}

// MARK: - View Modifiers
struct AACardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AATheme.paddingMedium)
            .background(AATheme.cardBackground)
            .cornerRadius(AATheme.cornerRadius)
            .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
    }
}

struct AAPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .serif, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AATheme.steel)
            .cornerRadius(AATheme.cornerRadius)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct AASecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .serif, weight: .semibold))
            .foregroundColor(AATheme.steel)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AATheme.steel.opacity(0.1))
            .cornerRadius(AATheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AATheme.cornerRadius)
                    .stroke(AATheme.steel.opacity(0.3), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}

struct AAPremiumButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .serif, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AATheme.premiumGradient)
            .cornerRadius(AATheme.cornerRadius)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}

// MARK: - View Extensions
extension View {
    func aaCard() -> some View {
        modifier(AACardModifier())
    }

    func aaScreenBackground() -> some View {
        self.background(AATheme.background.ignoresSafeArea())
    }
}
