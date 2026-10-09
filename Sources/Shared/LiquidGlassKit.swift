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

extension SCPContainmentClass {
    var glowColor: Color {
        switch self {
        case .safe:
            return .green
        case .euclid:
            return .yellow
        case .keter:
            return .red
        case .thaumiel:
            return .blue
        }
    }

    var glowLabel: String {
        switch self {
        case .safe: return "Зелёное свечение"
        case .euclid: return "Жёлтое свечение"
        case .keter: return "Красное свечение"
        case .thaumiel: return "Синее свечение"
        }
    }
}

private struct SCPClassGlowModifier: ViewModifier {
    let containmentClass: SCPContainmentClass

    func body(content: Content) -> some View {
        content
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(containmentClass.glowColor.opacity(0.82), lineWidth: 1.5)
                    .shadow(color: containmentClass.glowColor.opacity(0.78), radius: 13)
                    .shadow(color: containmentClass.glowColor.opacity(0.34), radius: 28)
            }
    }
}

extension View {
    func scpClassGlow(_ containmentClass: SCPContainmentClass) -> some View {
        modifier(SCPClassGlowModifier(containmentClass: containmentClass))
    }
}


// MARK: - SCP danger highlight feature

enum SCPDangerClass: String, CaseIterable, Identifiable {
    case safe = "Safe"
    case euclid = "Euclid"
    case keter = "Keter"
    case thaumiel = "Thaumiel"

    var id: String { rawValue }

    var russianName: String {
        switch self {
        case .safe: return "Безопасный"
        case .euclid: return "Евклид"
        case .keter: return "Кетер"
        case .thaumiel: return "Таумиель"
        }
    }

    var color: Color {
        switch self {
        case .safe: return .green
        case .euclid: return .yellow
        case .keter: return .red
        case .thaumiel: return .blue
        }
    }

    var backgroundColor: Color { color.opacity(0.12) }
    var borderColor: Color { color.opacity(0.55) }

    var glowRadius: CGFloat {
        switch self {
        case .safe: return 8
        case .euclid: return 10
        case .keter: return 14
        case .thaumiel: return 11
        }
    }

    static func from(_ value: String) -> SCPDangerClass {
        switch value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "safe", "безопасный", "безопасно": return .safe
        case "euclid", "евклид": return .euclid
        case "keter", "кетер": return .keter
        case "thaumiel", "таумиель": return .thaumiel
        default: return .safe
        }
    }

    static func from(_ containmentClass: SCPContainmentClass) -> SCPDangerClass {
        switch containmentClass {
        case .safe: return .safe
        case .euclid: return .euclid
        case .keter: return .keter
        case .thaumiel: return .thaumiel
        }
    }
}

struct SCPDangerHighlightModifier: ViewModifier {
    let dangerClass: SCPDangerClass

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(dangerClass.backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(dangerClass.borderColor, lineWidth: 1)
            )
            .shadow(
                color: dangerClass.color.opacity(0.32),
                radius: dangerClass.glowRadius,
                x: 0,
                y: 0
            )
    }
}

extension View {
    func scpDangerHighlight(_ dangerClass: SCPDangerClass) -> some View {
        modifier(SCPDangerHighlightModifier(dangerClass: dangerClass))
    }
}

struct SCPDangerBadge: View {
    let dangerClass: SCPDangerClass

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(dangerClass.color)
                .frame(width: 7, height: 7)
                .shadow(color: dangerClass.color.opacity(0.8), radius: 4)

            Text(dangerClass.russianName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(dangerClass.color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(dangerClass.backgroundColor))
        .overlay(Capsule().stroke(dangerClass.borderColor, lineWidth: 1))
    }
}
