import SwiftUI

extension View {
    func footCardStyle(cornerRadius: CGFloat = 14) -> some View {
        self
            .background(
                LinearGradient(
                    colors: [Color.footCard, Color.footCard.opacity(0.78)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
            .cornerRadius(cornerRadius)
            .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 6)
    }
    
    func footGlow(_ color: Color = .footSuccess) -> some View {
        self
            .shadow(color: color.opacity(0.32), radius: 10, x: 0, y: 0)
            .shadow(color: color.opacity(0.18), radius: 18, x: 0, y: 0)
    }
}

