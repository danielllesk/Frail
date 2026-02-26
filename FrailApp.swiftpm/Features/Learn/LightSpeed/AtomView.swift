//
//  AtomView.swift
//  Frail
//
//  Animated atom visualization
//

import SwiftUI

struct AtomView: View {
    let speedOfLightMultiplier: Double
    
    @State private var electronAngle: Double = 0
    @State private var animationTimer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let baseRadius = min(geometry.size.width, geometry.size.height) * 0.15
            let atomScale = atomSizeMultiplier
            
            ZStack {
                // Electron shells
                ForEach(0..<3) { shell in
                    let radius = baseRadius * Double(shell + 1) * atomScale
                    Circle()
                        .stroke(Color.frailAccent.opacity(0.3), lineWidth: 1)
                        .frame(width: radius * 2, height: radius * 2)
                        .position(center)
                }
                
                // Nucleus
                Circle()
                    .fill(Color.frailGold)
                    .frame(width: 20 * atomScale, height: 20 * atomScale)
                    .position(center)
                
                // Electrons
                ForEach(0..<6) { electron in
                    let shell = electron / 2
                    let radius = baseRadius * Double(shell + 1) * atomScale
                    let angle = electronAngle + Double(electron) * 60
                    let x = center.x + radius * cos(angle * .pi / 180)
                    let y = center.y + radius * sin(angle * .pi / 180)
                    
                    Circle()
                        .fill(Color.frailAccent)
                        .frame(width: 8, height: 8)
                        .position(x: x, y: y)
                }
            }
        }
        .onAppear {
            startElectronAnimation()
        }
        .onDisappear {
            animationTimer?.invalidate()
            animationTimer = nil
        }
        .onChange(of: speedOfLightMultiplier) { _ in
            startElectronAnimation()
        }
    }
    
    private var atomSizeMultiplier: Double {
        // Slower light = larger atoms
        return 1.0 / speedOfLightMultiplier
    }
    
    private func startElectronAnimation() {
        animationTimer?.invalidate()
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            Task { @MainActor in
                withAnimation(.linear(duration: 0.016)) {
                    electronAngle += 2
                    if electronAngle >= 360 {
                        electronAngle = 0
                    }
                }
            }
        }
    }
}
