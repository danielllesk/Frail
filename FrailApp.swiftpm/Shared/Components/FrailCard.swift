//
//  FrailCard.swift
//  Frail
//
//  Reusable glassmorphism card component
//

import SwiftUI

struct FrailCard: View {
    let title: String
    let subtitle: String
    let index: Int
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Section number
                Text(String(format: "%02d", index))
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundColor(.frailGold)
                    .frame(width: 28, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.frailPrimaryText)
                        .tracking(0.3)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.frailMutedText)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Subtle chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.frailMutedText.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(
                                Color.frailMentorBorder.opacity(isPressed ? 0.8 : 0.3),
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
