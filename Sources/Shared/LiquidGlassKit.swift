import Foundation
import SwiftUI

var isVersion26OrLater: Bool {
    ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26
}

struct LiquidGlassBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    private var gradientColors: [Color] {
        if colorScheme == .dark {
            return [
                Color(red: 0.05, green: 0.09, blue: 0.16),
                Color(red: 0.02, green: 0.06, blue: 0.11),
                Color(red: 0.03, green: 0.04, blue: 0.09)
            ]
        }
        return [
            Color(red: 0.90, green: 0.95, blue: 1.00),
            Color(red: 0.82, green: 0.90, blue: 0.99),
            Color(red: 0.93, green: 0.96, blue: 1.00)
        ]
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(
                    Color.cyan.opacity(
                        colorScheme == .dark
                            ? (isVersion26OrLater ? 0.25 : 0.14)
                            : (isVersion26OrLater ? 0.18 : 0.10)
                    )
                )
                .frame(width: 280, height: 280)
                .blur(radius: isVersion26OrLater ? 64 : 42)
                .offset(x: 140, y: -220)

            Circle()
                .fill(
                    Color.blue.opacity(
                        colorScheme == .dark
                            ? (isVersion26OrLater ? 0.20 : 0.10)
                            : (isVersion26OrLater ? 0.14 : 0.08)
                    )
                )
                .frame(width: 320, height: 320)
                .blur(radius: isVersion26OrLater ? 74 : 48)
                .offset(x: -160, y: 260)
        }
        .ignoresSafeArea()
    }
}

private struct LiquidGlassCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.regularMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(isVersion26OrLater ? 0.24 : 0.10),
                                        Color.cyan.opacity(isVersion26OrLater ? 0.11 : 0.04),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(isVersion26OrLater ? 0.50 : 0.22),
                                Color.white.opacity(0.06)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isVersion26OrLater ? 1.2 : 0.8
                    )
            )
            .shadow(
                color: Color.black.opacity(isVersion26OrLater ? 0.22 : 0.12),
                radius: isVersion26OrLater ? 16 : 8,
                y: isVersion26OrLater ? 7 : 4
            )
    }
}

extension View {
    func liquidGlassCard(
        cornerRadius: CGFloat = 16,
        horizontalPadding: CGFloat = 12,
        verticalPadding: CGFloat = 12
    ) -> some View {
        modifier(
            LiquidGlassCardModifier(
                cornerRadius: cornerRadius,
                horizontalPadding: horizontalPadding,
                verticalPadding: verticalPadding
            )
        )
    }
}
