//
//  MysteryData.swift
//  Frail
//
//  Data for the "Dead Universe" challenge mode.
//

import Foundation

struct MysteryUniverse: Identifiable {
    let id: Int
    let clues: [String]
    let options: [String]
    let correctIndex: Int
    let successExplanation: String
}

struct MysteryData {
    static let mysteries: [MysteryUniverse] = [
        MysteryUniverse(
            id: 0,
            clues: [
                "The stars burned bright — and briefly. Most collapsed within a billion years.",
                "Planets formed close to their stars. Their surfaces were crushed flat.",
                "No moon-sized bodies remain. Tidal forces tore them apart."
            ],
            options: ["Gravity too strong", "Speed of light too low", "Planet mass too high", "Star burned too cool"],
            correctIndex: 0,
            successExplanation: "Strong gravity accelerates stellar evolution. Stars exhaust their fuel fast. No time for complexity."
        ),
        MysteryUniverse(
            id: 1,
            clues: [
                "Atoms in this universe are large — bloated, unstable.",
                "No solid surfaces formed. Matter could not compress into rock.",
                "Chemistry here produced only the simplest elements. Nothing complex."
            ],
            options: ["Gravity too weak", "Speed of light too low", "Planet mass too low", "Expansion too fast"],
            correctIndex: 1,
            successExplanation: "A slower light changes the fine-structure constant. Atoms lose stability. Chemistry loses range."
        ),
        MysteryUniverse(
            id: 2,
            clues: [
                "The inner planets bear the scars of constant impact. Craters cover everything.",
                "No large body orbits far from the star. The outer system is empty.",
                "Comets arrive frequently. The inner system is bombarded without pause."
            ],
            options: ["No magnetic field", "Speed of light too high", "No outer gas giant", "Gravity too weak"],
            correctIndex: 2,
            successExplanation: "Jupiter intercepts debris that would otherwise devastate inner planets. Remove it — and the inner system never stabilises."
        )
    ]
}

struct RapidFireRound: Identifiable {
    let id: Int
    let gravity: Double
    let lightSpeed: Double
    let mass: Double
    let isPossible: Bool
    let explanation: String
}

struct RapidFireData {
    static let rounds: [RapidFireRound] = [
        RapidFireRound(
            id: 0,
            gravity: 0.1,
            lightSpeed: 1.0,
            mass: 1.0,
            isPossible: false,
            explanation: "Gravity too weak. Atmospheres escape. Oceans evaporate. Life has no foundation."
        ),
        RapidFireRound(
            id: 1,
            gravity: 1.0,
            lightSpeed: 0.5,
            mass: 2.0,
            isPossible: false,
            explanation: "Light speed at half value destabilises atomic chemistry. The building blocks don't hold."
        ),
        RapidFireRound(
            id: 2,
            gravity: 1.2,
            lightSpeed: 1.0,
            mass: 1.5,
            isPossible: true,
            explanation: "Slightly stronger gravity. Denser planets. Thicker atmospheres. Harder — but not impossible."
        )
    ]
}
