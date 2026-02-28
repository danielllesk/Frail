//
//  WitnessViewModel.swift
//  Frail
//
//  State for the galaxy collision witness experience.
//

import SwiftUI

@MainActor
final class WitnessViewModel: ObservableObject {
    
    @Published var scrubProgress: Double = 0.0 // 0.0 to 1.0
    
    var currentNovaLine: String {
        switch scrubProgress {
        case ..<0.15: return "Two galaxies, each containing hundreds of billions of stars. They have been falling toward each other for billions of years."
        case 0.15..<0.35: return "They pass through each other. Stars almost never collide — the distances are too vast. But gravity distorts everything."
        case 0.35..<0.55: return "Long streams of stars are pulled out by tidal forces. Bridges of light between two dying structures."
        case 0.55..<0.75: return "Gravity will not let them escape. They fall back toward each other. This is inevitable."
        case 0.75..<0.9: return "They are becoming one. New stars ignite from the compressed gas. The violence creates."
        default: return "A single elliptical galaxy remains. Quieter now. Most star formation complete. A new structure — born from collision."
        }
    }
}
