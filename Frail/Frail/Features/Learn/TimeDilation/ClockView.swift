//
//  ClockView.swift
//  Frail
//
//  Individual animated clock component
//

import SwiftUI

struct ClockView: View {
    let timeMultiplier: Double
    let label: String
    
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Clock face
                Circle()
                    .stroke(Color.frailMutedText.opacity(0.3), lineWidth: 2)
                    .frame(width: 120, height: 120)
                
                // Hour markers
                ForEach(0..<12) { hour in
                    Rectangle()
                        .fill(Color.frailMutedText.opacity(0.5))
                        .frame(width: 2, height: 8)
                        .offset(y: -50)
                        .rotationEffect(.degrees(Double(hour) * 30))
                }
                
                // Second hand
                Rectangle()
                    .fill(Color.frailAccent)
                    .frame(width: 2, height: 50)
                    .offset(y: -25)
                    .rotationEffect(.degrees(rotation))
            }
            
            Text(label)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.frailMutedText)
            
            Text(String(format: "%.2fx", timeMultiplier))
                .font(.system(size: 20, weight: .medium, design: .monospaced))
                .foregroundColor(.frailGold)
        }
        .onAppear {
            startClock()
        }
        .onChange(of: timeMultiplier) {
            startClock()
        }
    }
    
    private func startClock() {
        let baseInterval: TimeInterval = 1.0
        let adjustedInterval = baseInterval / timeMultiplier
        
        Timer.scheduledTimer(withTimeInterval: adjustedInterval, repeats: true) { _ in
            withAnimation(.linear(duration: adjustedInterval)) {
                rotation += 6 // 6 degrees per second
            }
        }
    }
}
