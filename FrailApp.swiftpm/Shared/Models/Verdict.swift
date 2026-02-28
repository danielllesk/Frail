//
//  Verdict.swift
//  Frail
//
//  Scoring outcomes for the Build section.
//

import SwiftUI

enum Verdict: String {
    case stable = "Stable"
    case marginal = "Marginal"
    case unstable = "Unstable"
    case collapse = "Collapse"
    
    var color: Color {
        switch self {
        case .stable: return .green // Emerald placeholder
        case .marginal: return .frailGold
        case .unstable: return .frailAmber
        case .collapse: return .frailCrimson
        }
    }
    
    var novaState: NovaState {
        switch self {
        case .stable: return .affirming
        case .marginal: return .neutral
        case .unstable: return .warning
        case .collapse: return .critical
        }
    }
    
    static func from(score: Double) -> Verdict {
        switch score {
        case 75...100: return .stable
        case 50..<75: return .marginal
        case 25..<50: return .unstable
        default: return .collapse
        }
    }
}
