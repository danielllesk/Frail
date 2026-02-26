//
//  OrbitView.swift
//  Frail
//
//  2.5D orbit animation
//

import SwiftUI

struct OrbitView: View {
    let gravityMultiplier: Double
    
    @State private var moonAngle: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let orbitRadius = min(geometry.size.width, geometry.size.height) * 0.3 * orbitScale
            
            ZStack {
                // Orbit path
                Circle()
                    .stroke(Color.frailMutedText.opacity(0.2), lineWidth: 1)
                    .frame(width: orbitRadius * 2, height: orbitRadius * 2)
                    .position(center)
                
                // Earth (center)
                Circle()
                    .fill(Color.frailAccent)
                    .frame(width: 40, height: 40)
                    .position(center)
                
                // Moon
                let moonX = center.x + orbitRadius * cos(moonAngle * .pi / 180)
                let moonY = center.y + orbitRadius * sin(moonAngle * .pi / 180)
                
                Circle()
                    .fill(Color.frailMutedText)
                    .frame(width: 16, height: 16)
                    .position(x: moonX, y: moonY)
            }
        }
        .onAppear {
            startOrbit()
        }
        .onChange(of: gravityMultiplier) {
            startOrbit()
        }
    }
    
    private var orbitScale: Double {
        // Stronger gravity = tighter orbit
        return 1.0 / sqrt(gravityMultiplier)
    }
    
    private func startOrbit() {
        // Orbital period decreases with stronger gravity
        let basePeriod: TimeInterval = 3.0
        let adjustedPeriod = basePeriod / sqrt(gravityMultiplier)
        
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            withAnimation(.linear(duration: 0.016)) {
                let increment = 360.0 / (adjustedPeriod * 60.0) // 60 FPS
                moonAngle += increment
                if moonAngle >= 360 {
                    moonAngle = 0
                }
            }
        }
    }
}
