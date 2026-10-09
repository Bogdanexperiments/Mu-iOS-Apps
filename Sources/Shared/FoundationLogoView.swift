import SwiftUI

struct FoundationLogoView: View {
    var size: CGFloat = 100
    var lineWidth: CGFloat { max(2, size * 0.08) }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.primary, lineWidth: lineWidth)
                .frame(width: size, height: size)

            Circle()
                .fill(Color.primary)
                .frame(width: size * 0.25, height: size * 0.25)

            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(Color.primary)
                    .frame(width: lineWidth, height: size * 0.36)
                    .offset(y: -size * 0.29)
                    .rotationEffect(.degrees(Double(index) * 120))
            }
        }
        .accessibilityLabel("SCP Foundation")
    }
}
