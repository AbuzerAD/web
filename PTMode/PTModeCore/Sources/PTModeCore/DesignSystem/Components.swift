import SwiftUI

/// Primary button.
public struct PTButton: View {
    public enum Style { case primary, secondary, ghost, danger }
    let title: String
    let style: Style
    let action: () -> Void
    let isLoading: Bool

    public init(_ title: String, style: Style = .primary, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title; self.style = style; self.isLoading = isLoading; self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: PTTheme.Spacing.sm) {
                if isLoading { ProgressView().tint(foreground) }
                Text(title).font(PTTheme.Typography.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(background)
            .foregroundStyle(foreground)
            .clipShape(RoundedRectangle(cornerRadius: PTTheme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: PTTheme.Radius.md)
                    .stroke(borderColor, lineWidth: style == .secondary || style == .ghost ? 1 : 0)
            )
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }

    private var background: Color {
        switch style {
        case .primary: return PTTheme.Colors.primary
        case .secondary: return .clear
        case .ghost: return PTTheme.Colors.primary.opacity(0.08)
        case .danger: return PTTheme.Colors.danger
        }
    }
    private var foreground: Color {
        switch style {
        case .primary, .danger: return .white
        case .secondary: return PTTheme.Colors.textPrimary
        case .ghost: return PTTheme.Colors.primary
        }
    }
    private var borderColor: Color {
        switch style {
        case .secondary: return PTTheme.Colors.border
        default: return .clear
        }
    }
}

/// Card container.
public struct PTCard<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }
    public var body: some View {
        content
            .padding(PTTheme.Spacing.lg)
            .background(PTTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: PTTheme.Radius.lg))
            .shadow(color: PTTheme.cardShadow.color, radius: PTTheme.cardShadow.radius,
                    x: PTTheme.cardShadow.x, y: PTTheme.cardShadow.y)
    }
}

/// Section header.
public struct PTSectionHeader: View {
    let title: String
    let subtitle: String?
    public init(_ title: String, subtitle: String? = nil) { self.title = title; self.subtitle = subtitle }
    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(PTTheme.Typography.title2).foregroundStyle(PTTheme.Colors.textPrimary)
            if let s = subtitle {
                Text(s).font(PTTheme.Typography.subheadline).foregroundStyle(PTTheme.Colors.textSecondary)
            }
        }
    }
}

/// Pill tag.
public struct PTPill: View {
    let text: String
    let color: Color
    public init(_ text: String, color: Color = PTTheme.Colors.primary) { self.text = text; self.color = color }
    public var body: some View {
        Text(text)
            .font(PTTheme.Typography.caption)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(color.opacity(0.12))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

/// Empty state.
public struct PTEmptyState: View {
    let icon: String
    let title: String
    let message: String
    public init(icon: String, title: String, message: String) { self.icon = icon; self.title = title; self.message = message }
    public var body: some View {
        VStack(spacing: PTTheme.Spacing.md) {
            Image(systemName: icon).font(.system(size: 44)).foregroundStyle(PTTheme.Colors.textTertiary)
            Text(title).font(PTTheme.Typography.headline)
            Text(message).font(PTTheme.Typography.subheadline).foregroundStyle(PTTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(PTTheme.Spacing.xxl)
    }
}
