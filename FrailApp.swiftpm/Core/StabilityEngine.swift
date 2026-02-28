//
//  StabilityEngine.swift
//  Frail
//
//  Calculates the stability score of a custom-built universe.
//

import Foundation

struct StabilityEngine {
    
    struct UniverseState {
        let gravity: Double
        let lightSpeed: Double
        let starType: PhysicsConstants.StarType
        let planetMasses: [Double]
        let planetOrbits: [Double]
    }
    
    /// Main entry point for scoring. Max score = 100.
    /// Our specific benchmark constellation should result in exactly 94.
    static func calculateStability(for state: UniverseState) -> Double {
        var total: Double = 0
        
        // 1. Foundation Baseline: 30 pts
        total += 30.0
        
        // 2. Star Habitability (0 to 25 pts)
        total += calculateStarScore(state.starType)
        
        // 3. Orbital Spacing (0 to 25 pts)
        total += calculateOrbitalScore(orbits: state.planetOrbits)
        
        // 4. Mass Distribution (0 to 20 pts)
        total += calculateMassDistributionScore(masses: state.planetMasses, orbits: state.planetOrbits)
        
        // 5. Constants Penalties (Capped at 25 each)
        // Tolerance Band: 0.7 to 1.3 is safe (zero penalty)
        let gravityDelta = max(0, abs(state.gravity - 1.0) - 0.3)
        let lightDelta = max(0, abs(state.lightSpeed - 1.0) - 0.3)
        
        let gravityPenalty = min(25.0, gravityDelta * 20.0)
        let lightPenalty = min(25.0, lightDelta * 20.0)
        
        total -= gravityPenalty
        total -= lightPenalty
        
        // 6. Cosmic Imperfection (The 6-point anchor)
        // This ensures the maximum "perfect" stable state scores 94.
        total -= 6.0
        
        return max(0, min(100, total))
    }
    
    private static func calculateStarScore(_ starType: PhysicsConstants.StarType) -> Double {
        switch starType {
        case .yellowSun: return 25
        case .orangeKType: return 20
        case .redDwarf: return 12
        case .blueGiant: return 5
        case .whiteDwarf: return 3
        }
    }
    
    private static func calculateOrbitalScore(orbits: [Double]) -> Double {
        var score: Double = 25.0
        let sorted = orbits.sorted()
        
        // Ratio penalty (Graduated)
        for i in 0..<(sorted.count - 1) {
            let ratio = sorted[i+1] / sorted[i]
            if ratio < 1.4 {
                let severity = (1.4 - ratio) / 1.4
                score -= 8.0 * (0.5 + severity * 0.5)
            }
        }
        
        // Inner radius penalty (Cutoff 0.5 AU)
        for orbit in orbits {
            if orbit < 0.5 {
                score -= 10.0
            }
        }
        
        return max(0, score)
    }
    
    private static func calculateMassDistributionScore(masses: [Double], orbits: [Double]) -> Double {
        var score: Double = 20.0
        let indexed = orbits.enumerated().sorted(by: { $0.element < $1.element })
        
        guard indexed.count >= 2 else { return score }
        
        // Check all inner planets (all except the outermost)
        let innerPlanetCount = max(1, indexed.count - 1)
        for i in 0..<innerPlanetCount {
            if masses[indexed[i].offset] > 2.0 {
                score -= 8.0
            }
        }
        
        // Check outer planet (sweep/shielding)
        let outerIndex = indexed.last!.offset
        if masses[outerIndex] < 2.5 { // Adjusted threshold to be fairer
            score -= 10.0
        }
        
        return max(0, score)
    }
    
    /// Identifies the "Lesson" that explains a failure. 
    /// Takes the current score to avoid redundant recalculation.
    static func getFailureReason(for state: UniverseState, score: Double) -> String {
        // 1. Star Match & Ceiling Check (Highest Priority)
        let maxPossible = state.starType.theoreticalMaxScore
        
        if abs(score - maxPossible) < 0.1 {
            if state.starType == .yellowSun {
                return "This matches the best configuration I found for this star. 94 points. The configuration this universe chose. I wonder if you can match it... oh, you already did. Perhaps try another star?"
            }
            if state.starType == .blueGiant || state.starType == .whiteDwarf {
                return "This matches the best configuration I found for this star. \(Int(maxPossible)) points. Structurally stable — but this star will be dead before life can begin. Move on to another star to see if you can find higher peaks."
            }
            return "This matches the best configuration I found for this star. \(Int(maxPossible)) points. Perhaps there is nothing left to find here... or perhaps you should try a different star to reach higher peaks."
        }
        
        if score >= maxPossible - 2.0 {
            if state.starType == .blueGiant || state.starType == .whiteDwarf {
                return "This is the best I found for this star. \(Int(maxPossible)) points. Some universes have limits. Perhaps you see something I missed."
            }
            return "This is the best I found for this star. \(Int(maxPossible)) points. Some universes have limits. Perhaps you see something I missed."
        }

        // 2. Fundamental Constants (Highest Impact)
        let gravityDelta = abs(state.gravity - 1.0)
        let lightDelta = abs(state.lightSpeed - 1.0)
        
        if score < 35.0 && abs(state.gravity - 0.1) < 0.05 {
            return "This universe is an embryo. Choose its constants. Set its foundations."
        }
        
        if gravityDelta > lightDelta && gravityDelta > 0.5 {
            return "Orbital mechanics cannot hold these planets. Gravity is too dominant or too weak."
        }
        if lightDelta > 0.5 {
            return "Constants do not permit stable atoms. Matter itself reaches a dead end."
        }
        
        // 3. Star Viability
        if state.starType == .blueGiant {
            return "Your star burns too hot — and too briefly. Complexity needs billions of years to emerge."
        }
        if state.starType == .whiteDwarf {
            return "Your star is dying. A white dwarf cannot sustain a habitable zone long enough for complexity."
        }
        
        // 4. Orbital Integrity
        let sorted = state.planetOrbits.sorted()
        for i in 0..<(sorted.count - 1) {
            if sorted[i+1] / sorted[i] < 1.4 {
                return "The inner planets are too close. Tidal forces will tear them apart."
            }
        }
        // Threshold: 0.5 AU is safe, < 0.5 is scorched.
        if sorted.first ?? 0 < 0.5 {
            return "A planet is too close to its star. Life would be scorched before it begins."
        }
        
        // 5. Mass Distribution
        let indexed = state.planetOrbits.enumerated().sorted(by: { $0.element < $1.element })
        if indexed.count >= 2 {
            let innerCount = max(1, indexed.count - 1)
            for i in 0..<innerCount {
                if state.planetMasses[indexed[i].offset] > 2.0 {
                    return "Your inner planets are too massive. Their gravity destabilises the system from within."
                }
            }
            if state.planetMasses[indexed.last!.offset] < 2.5 {
                return "Your system lacks a massive outer protector. Comets and debris would devastate the inner worlds."
            }
        }
        
        return "The universe is fragile, but you have found a stable configuration."
    }
}
