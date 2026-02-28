//
//  PhysicsConstants.swift
//  Frail
//
//  Central source for all physics ranges and benchmark values.
//

import Foundation
import UIKit

struct PhysicsConstants {
    
    // MARK: - Global Constants
    struct Universal {
        static let gravityRange: ClosedRange<Double> = 0.1...5.0
        static let lightSpeedRange: ClosedRange<Double> = 0.1...5.0
        
        // The "Perfect" Benchmarks (Our Universe)
        static let optimalGravity: Double = 1.0
        static let optimalLightSpeed: Double = 1.0
        
        static let benchmarkStability: Double = 94.0
    }
    
    // MARK: - Star Properties
    enum StarType: String, CaseIterable, Identifiable {
        case redDwarf = "Red Dwarf"
        case orangeKType = "Orange Dwarf"
        case yellowSun = "Yellow Sun"  // The Baseline
        case blueGiant = "Blue Giant"
        case whiteDwarf = "White Dwarf"
        
        var id: String { rawValue }
        
        var starColor: UIColor {
            switch self {
            case .redDwarf: return UIColor(red: 0x8B/255.0, green: 0x1A/255.0, blue: 0x1A/255.0, alpha: 1.0)
            case .orangeKType: return UIColor(red: 0xD9/255.0, green: 0x7B/255.0, blue: 0x3A/255.0, alpha: 1.0)
            case .yellowSun: return UIColor(red: 0xC9/255.0, green: 0xA8/255.0, blue: 0x4C/255.0, alpha: 1.0)
            case .blueGiant: return UIColor(red: 0x4A/255.0, green: 0x90/255.0, blue: 0xD9/255.0, alpha: 1.0)
            case .whiteDwarf: return UIColor(red: 0xF0/255.0, green: 0xED/255.0, blue: 0xE6/255.0, alpha: 1.0)
            }
        }
        
        struct OptimalConfig {
            let gravity: Double
            let lightSpeed: Double
            let masses: [Double]
            let orbits: [Double]
        }
        
        var optimalConfig: OptimalConfig {
            switch self {
            case .yellowSun:
                return OptimalConfig(gravity: 1.0, lightSpeed: 1.0, masses: [1.0, 1.0, 4.0], orbits: [0.5, 1.0, 2.5])
            case .orangeKType:
                return OptimalConfig(gravity: 1.0, lightSpeed: 1.0, masses: [1.0, 1.0, 4.0], orbits: [0.5, 1.0, 2.5])
            case .redDwarf:
                return OptimalConfig(gravity: 1.0, lightSpeed: 1.0, masses: [0.8, 1.2, 3.0], orbits: [0.5, 1.0, 2.0])
            case .blueGiant:
                return OptimalConfig(gravity: 1.0, lightSpeed: 1.0, masses: [1.0, 1.5, 3.0], orbits: [0.5, 1.2, 3.0])
            case .whiteDwarf:
                return OptimalConfig(gravity: 1.0, lightSpeed: 1.0, masses: [0.5, 1.0, 3.0], orbits: [0.5, 1.0, 2.5])
            }
        }
        
        var theoreticalMaxScore: Double {
            switch self {
            case .yellowSun:   return 94.0
            case .orangeKType: return 89.0
            case .redDwarf:    return 81.0
            case .blueGiant:   return 74.0
            case .whiteDwarf:  return 72.0
            }
        }
    }
    
    // MARK: - Planet Properties
    struct Planets {
        static let count = 3
        static let massRange: ClosedRange<Double> = 0.1...5.0 // Earth masses
        static let orbitRange: ClosedRange<Double> = 0.3...4.5 // AU - Lowered min to allow reachable penalty
        
        // Ideal Spacing: Ratio between adjacent orbits should be > 1.4
        static let minimumSpacingRatio: Double = 1.4
    }
}
