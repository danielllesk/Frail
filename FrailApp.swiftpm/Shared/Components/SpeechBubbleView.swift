//
//  SpeechBubbleView.swift
//  Frail
//
//  Bubble + text + auto-dismiss
//

import SwiftUI

struct SpeechBubbleView: View {
    let text: String
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .bottom, spacing: 12) {
                // Speech bubble
                Text(text)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(Color.frailPrimaryText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.frailMentorBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.frailMentorBorder, lineWidth: 1)
                            )
                    )
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 20)
                
                Spacer()
            }
            .padding(.leading, 60) // Space for Nova orb
        }
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                isVisible = true
            }
            
            // Auto-dismiss after 6 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                dismiss()
            }
        }
        .onTapGesture {
            dismiss()
        }
    }
    
    private func dismiss() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}
