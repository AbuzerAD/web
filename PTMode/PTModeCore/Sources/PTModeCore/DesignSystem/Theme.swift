import SwiftUI

/// PTMode design tokens. Override these to match your Figma design.
public enum PTTheme {
    // MARK: - Colors (from Figma PTMode Portal UI)
    public enum Colors {
        public static let primary = Color(hex: "#008AE6")
        public static let primaryDark = Color(hex: "#0072BE")
        public static let primaryLight = Color(hex: "#1AA3FF")
        public static let accent = Color(hex: "#27D06E")
        public static let accentLight = Color(hex: "#E4F9DB")
        public static let background = Color(hex: "#F2F2F2")
        public static let surface = Color.white
        public static let surfaceElevated = Color(hex: "#FFFFFF")
        public static let textPrimary = Color(hex: "#0D0D0D")
        public static let textSecondary = Color(hex: "#737373")
        public static let textTertiary = Color(hex: "#A6A6A6")
        public static let border = Color(hex: "#D9D9D9")
        public static let success = Color(hex: "#27D06E")
        public static let info = Color(hex: "#E5F5FF")
        public static let infoText = Color(hex: "#008AE6")
        public static let warning = Color(hex: "#F59E0B")
        public static let danger = Color(hex: "#EB5757")
        public static let rest = Color(hex: "#4DB8FF")
    }

    // MARK: - Typography (Montserrat headings, Roboto body — bundle these fonts in the app)
    public enum Typography {
        public static let largeTitle = Font.custom("Montserrat", size: 32).weight(.bold)
        public static let title = Font.custom("Montserrat", size: 24).weight(.bold)
        public static let title2 = Font.custom("Montserrat", size: 20).weight(.semibold)
        public static let headline = Font.custom("Montserrat", size: 17).weight(.semibold)
        public static let body = Font.custom("Roboto", size: 16).weight(.regular)
        public static let callout = Font.custom("Roboto", size: 15).weight(.regular)
        public static let subheadline = Font.custom("Roboto", size: 14).weight(.regular)
        public static let caption = Font.custom("Roboto", size: 12).weight(.regular)
        public static let mono = Font.system(size: 16, weight: .medium, design: .monospaced)
    }

    // MARK: - Spacing
    public enum Spacing {
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 12
        public static let lg: CGFloat = 16
        public static let xl: CGFloat = 24
        public static let xxl: CGFloat = 32
    }

    // MARK: - Radius
    public enum Radius {
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 12
        public static let lg: CGFloat = 16
        public static let xl: CGFloat = 24
        public static let pill: CGFloat = 999
    }

    // MARK: - Shadow
    public static let cardShadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) =
        (Color.black.opacity(0.06), 8, 0, 4)
}

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
