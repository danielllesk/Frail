//
//  VerdictView.swift
//  Frail
//
//  Score reveal overlay for the universe builder.
//

import SwiftUI

struct VerdictView: View {
    let score: Double
    let reason: String
    let universeName: String
    let onClose: () -> Void
    let onShowOptimal: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { onClose() }
            
            VStack(spacing: 32) {
                // Universe Name
                Text(universeName.uppercased())
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(.frailGold)
                    .tracking(4)
                
                // Score Circle
                ZStack {
                    Circle()
                        .stroke(Color.frailMentorBorder, lineWidth: 8)
                        .frame(width: 180, height: 180)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(score / 100))
                        .stroke(verdict.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 180, height: 180)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: -4) {
                        Text("\(Int(score))")
                            .font(.system(size: 64, weight: .black, design: .monospaced))
                        Text("/ 100")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.frailMutedText)
                    }
                }
                
                VStack(spacing: 12) {
                    Text("VERDICT: \(verdict.rawValue.uppercased())")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(verdict.color)
                        .tracking(2)
                    
                    Text(reason)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.frailPrimaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                VStack(spacing: 16) {
                    Button(action: onShowOptimal) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Nova's Optimal")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.frailBackground)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 40)
                        .background(
                            Capsule().fill(Color.frailGold)
                        )
                    }
                    
                    Button(action: onClose) {
                        Text("Refine Settings")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.frailMutedText)
                    }
                }
            }
            .padding(.vertical, 48)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.frailMentorBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color.frailMentorBorder, lineWidth: 1)
                    )
            )
            .padding(24)
        }
    }
    
    private var verdict: Verdict {
        Verdict.from(score: score)
    }
}
