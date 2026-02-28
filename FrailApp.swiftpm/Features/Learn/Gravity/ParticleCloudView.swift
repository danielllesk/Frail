//
//  ParticleCloudView.swift
//  Frail
//
//  Canvas-based particle cloud. Positions are COMPUTED from gravity
//  at render time — no onChange, no state mutation. The visual is
//  always a pure function of the gravity value.
//

import SwiftUI

struct ParticleCloudView: View {
    /// Gravity on a 0x–5x scale (matches the label the user sees).
    let gravityValue: Double
    /// When true, particles become bright star points (final phase).
    let showStars: Bool
    
    // Seed data — fixed once, never mutated.
    // Each particle has a deterministic home position and cluster assignment.
    private static let seeds: [ParticleSeed] = {
        // Generate deterministic seeds once
        var rng = SplitMix64(seed: 42)  // fixed seed = deterministic
        var s: [ParticleSeed] = []
        let count = 200
        for i in 0..<count {
            s.append(ParticleSeed(
                homeX: rng.nextDouble(in: 0.08...0.92),
                homeY: rng.nextDouble(in: 0.08...0.92),
                baseSize: rng.nextDouble(in: 1.5...3.0),
                baseBrightness: rng.nextDouble(in: 0.3...0.7),
                clusterIndex: i % ParticleCloudView.clusterCenters.count,
                jitterSeedX: rng.nextDouble(in: -1.0...1.0),
                jitterSeedY: rng.nextDouble(in: -1.0...1.0)
            ))
        }
        return s
    }()
    
    struct ParticleSeed {
        let homeX: Double       // uniform cloud position (0–1)
        let homeY: Double
        let baseSize: Double
        let baseBrightness: Double
        let clusterIndex: Int   // which cluster center (0–5)
        let jitterSeedX: Double // deterministic jitter so positions are stable
        let jitterSeedY: Double
    }
    
    // 6 cluster centers (where stars form when gravity is sufficient)
    private static let clusterCenters: [(Double, Double)] = [
        (0.25, 0.25), (0.75, 0.20),
        (0.50, 0.50), (0.20, 0.70),
        (0.80, 0.65), (0.55, 0.15)
    ]
    
    init(gravityValue: Double, showStars: Bool) {
        self.gravityValue = gravityValue
        self.showStars = showStars
    }
    
    var body: some View {
        Canvas { context, size in
            let g = gravityValue
            
            for seed in Self.seeds {
                // ── Compute position from gravity (pure equation) ──
                let (px, py, brightness, particleSize) = computeParticle(seed: seed, gravity: g)
                
                let screenX = px * size.width
                let screenY = py * size.height
                
                // Outer glow — appears once particles start clumping
                if showStars || g > 0.8 {
                    let glowR = particleSize * (showStars ? 5.0 : 3.0)
                    let glowRect = CGRect(
                        x: screenX - glowR, y: screenY - glowR,
                        width: glowR * 2, height: glowR * 2
                    )
                    let glowColor: Color = showStars
                        ? .white.opacity(brightness * 0.25)
                        : .frailAccent.opacity(brightness * 0.35)
                    context.fill(Circle().path(in: glowRect), with: .color(glowColor))
                }
                
                // Core dot
                let coreRect = CGRect(
                    x: screenX - particleSize, y: screenY - particleSize,
                    width: particleSize * 2, height: particleSize * 2
                )
                let color: Color = showStars
                    ? .white.opacity(brightness)
                    : Color(
                        red: 0.4 + brightness * 0.3,
                        green: 0.5 + brightness * 0.3,
                        blue: 0.7 + brightness * 0.3
                    ).opacity(brightness * 0.9)
                context.fill(Circle().path(in: coreRect), with: .color(color))
            }
        }
    }
    
    // MARK: - Pure position equation
    
    private func computeParticle(seed: ParticleSeed, gravity g: Double) -> (x: Double, y: Double, brightness: Double, size: Double) {
        let center = Self.clusterCenters[seed.clusterIndex]
        
        var x: Double
        var y: Double
        var brightness: Double
        var sz: Double
        
        if g < 0.4 {
            // LOW GRAVITY — scatter outward from center, particles dim
            let dx = seed.homeX - 0.5
            let dy = seed.homeY - 0.5
            let scatter = 1.5 + (0.4 - g) * 2.0
            let jx = seed.jitterSeedX * 0.03
            let jy = seed.jitterSeedY * 0.03
            x = 0.5 + dx * scatter + jx
            y = 0.5 + dy * scatter + jy
            brightness = max(0.05, 0.15 * (g / 0.4))
            sz = seed.baseSize
        } else if g < 0.8 {
            // WEAK GRAVITY — loose cloud, slight drift toward clusters
            let pull = (g - 0.4) / 0.4
            let spread = 0.2 * (1.0 - pull * 0.4)
            let jx = seed.jitterSeedX * spread
            let jy = seed.jitterSeedY * spread
            x = seed.homeX + (center.0 - seed.homeX) * pull * 0.3 + jx
            y = seed.homeY + (center.1 - seed.homeY) * pull * 0.3 + jy
            brightness = 0.2 + pull * 0.3
            sz = seed.baseSize
        } else {
            // STRONG GRAVITY — clumping into protostars (continuous across 0.8–5.0)
            let pull = min(1.0, (g - 0.8) / 4.2)
            let spread = 0.12 * (1.0 - pull * 0.9)
            let jx = seed.jitterSeedX * spread
            let jy = seed.jitterSeedY * spread
            x = seed.homeX + (center.0 - seed.homeX) * (0.3 + pull * 0.7) + jx
            y = seed.homeY + (center.1 - seed.homeY) * (0.3 + pull * 0.7) + jy
            brightness = 0.5 + pull * 0.5
            sz = seed.baseSize * (1.0 + pull * 0.8)
        }
        
        // showStars only boosts appearance — positions stay from gravity
        if showStars {
            brightness = max(brightness, 0.6 + abs(seed.jitterSeedX) * 0.4)
            sz *= 1.3
        }
        
        return (x, y, brightness, sz)
    }
}

// MARK: - Deterministic RNG (no randomness, fully reproducible)

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
}
