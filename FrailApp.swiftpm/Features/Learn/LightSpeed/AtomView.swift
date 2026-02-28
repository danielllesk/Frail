//
//  AtomView.swift
//  Frail
//
//  Canvas-based atom visualization.
//  The speed of light determines atomic stability, shell radius, and electron energy.
//

import SwiftUI

struct AtomView: View {
    let lightSpeed: Double // 0x to 5x scale (1.0 is normal)
    
    // Fixed seeds for nucleus particles
    private let nucleusSeeds: [NucleusSeed]
    
    struct NucleusSeed {
        let x: Double
        let y: Double
        let size: Double
        let colorType: Int // 0 for proton (accent), 1 for neutron (muted)
    }
    
    init(lightSpeed: Double) {
        self.lightSpeed = lightSpeed
        
        // Generate a dense central nucleus (cluster of protons/neutrons)
        var rng = SplitMix64(seed: 123)
        var seeds: [NucleusSeed] = []
        for _ in 0..<12 {
            seeds.append(NucleusSeed(
                x: rng.nextDouble(in: 0.45...0.55),
                y: rng.nextDouble(in: 0.45...0.55),
                size: rng.nextDouble(in: 8...12),
                colorType: rng.nextInt(in: 0...1)
            ))
        }
        self.nucleusSeeds = seeds
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            ZStack {
                Canvas { context, size in
                    // COHESIVE SCALING: The entire atom scales with c
                    let c = lightSpeed
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    
                    // Universal scale mapping: r ∝ c
                    // CLAMPED SCALING: We cap at 2.0 to keep it on screen, 
                    // but we'll use jitter/speed to show the "violent energy" above that.
                    let atomScale = CGFloat(min(3.5, max(0.15, c))) 
                    
                    // 1. Draw Nucleus
                    // The nucleus is a cluster of seeds. Their positions are relative to center.
                    for seed in nucleusSeeds {
                        // Offset from center is also scaled by atomScale
                        let offsetX = CGFloat(seed.x - 0.5) * 60 * atomScale
                        let offsetY = CGFloat(seed.y - 0.5) * 60 * atomScale
                        
                        let px = center.x + offsetX
                        let py = center.y + offsetY
                        
                        // Particle size also scales with atomScale
                        let baseR = CGFloat(seed.size) * atomScale
                        
                        // Jitter only at extremes, and very subtle
                        // NATURAL JITTER: Independent X/Y phases
                        let jitterAmount: CGFloat = (c < 0.4 || c > 4.0) ? 2.5 * atomScale : 0.0
                        let jX = jitterAmount * CGFloat(sin(time * 30 + seed.x * 100))
                        let jY = jitterAmount * CGFloat(cos(time * 27 + seed.y * 137))
                        
                        let r = baseR
                        let coreRect = CGRect(x: px - r + jX, y: py - r + jY, width: r * 2, height: r * 2)
                        let color = seed.colorType == 0 ? Color.frailAccent : Color.frailMutedText.opacity(0.6)
                        
                        context.fill(Circle().path(in: coreRect), with: .color(color))
                        
                        // Nucleus glow
                        let glowR = r * 1.5
                        let glowRect = CGRect(x: px - glowR + jX, y: py - glowR + jY, width: glowR * 2, height: glowR * 2)
                        context.fill(Circle().path(in: glowRect), with: .color(color.opacity(0.15)))
                    }
                    
                    // 2. Draw Electron Shells
                    // Shells scale their radius by atomScale
                    drawShell(context: context, center: center, atomScale: atomScale, baseRadius: 60, count: 2, c: c, time: time)
                    drawShell(context: context, center: center, atomScale: atomScale, baseRadius: 110, count: 4, c: c, time: time)
                }
            }
        }
    }
    
    private func drawShell(context: GraphicsContext, center: CGPoint, atomScale: CGFloat, baseRadius: CGFloat, count: Int, c: Double, time: TimeInterval) {
        let radius = baseRadius * atomScale
        
        // Dissolve effect at extremes
        let alpha: Double
        if c < 0.2 {
            alpha = max(0, (c - 0.1) / 0.1) // Dissolve at low c
        } else if c > 4.0 {
            alpha = max(0.4, 1.0 - (c - 4.0) / 2.0) // Faint instability at high c
        } else {
            alpha = 1.0
        }
        
        guard alpha > 0 else { return }
        
        // Shell ring
        var path = Path()
        path.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
        context.stroke(path, with: .color(.frailMutedText.opacity(0.15 * alpha)), lineWidth: 1)
        
        // Electrons
        // Visual speed: frantic at high c, slow/drifting at low c
        let speed = 0.8 + (1.2 * c / 5.0) 
        
        for i in 0..<count {
            let angle = (Double(i) / Double(count) * .pi * 2) + (time * speed)
            let ex = center.x + radius * CGFloat(cos(angle))
            let ey = center.y + radius * CGFloat(sin(angle))
            
            let eSize: CGFloat = 3 * (atomScale > 1.0 ? 1.0 : atomScale) 
            let eRect = CGRect(x: ex - eSize, y: ey - eSize, width: eSize * 2, height: eSize * 2)
            
            // Electron core
            context.fill(Circle().path(in: eRect), with: .color(.white.opacity(alpha)))
            
            // Electron glow
            let glowR = eSize * 3
            let glowRect = CGRect(x: ex - glowR, y: ey - glowR, width: glowR * 2, height: glowR * 2)
            context.fill(Circle().path(in: glowRect), with: .color(.frailAccent.opacity(0.4 * alpha)))
        }
    }
}

// MARK: - Deterministic RNG Helper
private struct SplitMix64 {
    var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9e3779b97f4a7c15
        var z = state
        z = (z ^ (z >> 30)) &* 0xbf58476d1ce4e5b9
        z = (z ^ (z >> 27)) &* 0x94d049bb133111eb
        return z ^ (z >> 31)
    }
    mutating func nextDouble(in range: ClosedRange<Double>) -> Double {
        let raw = Double(next() & 0x1FFFFFFFFFFFFF) / Double(0x1FFFFFFFFFFFFF)
        return range.lowerBound + raw * (range.upperBound - range.lowerBound)
    }
    mutating func nextInt(in range: ClosedRange<Int>) -> Int {
        let raw = next() % UInt64(range.upperBound - range.lowerBound + 1)
        return range.lowerBound + Int(raw)
    }
}
