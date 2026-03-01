//
//  WitnessTimer.swift
//  Frail
//
//  Supernova visibility day counter.
//

import SwiftUI

struct WitnessTimer: View {
    let dayCount: Int
    let isExpanding: Bool
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(isExpanding ? "EXPANDING NEBULA" : "SUPERNOVA VISIBLE")
                .font(.system(size: 10, weight: .black))
                .foregroundColor(.frailGold)
                .tracking(2)
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                if isExpanding {
                    Text("~1,000")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text("years remaining")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.frailMutedText)
                } else {
                    Text("Day \(dayCount)")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text("of 23")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.frailMutedText)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.4))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
        )
    }
}
