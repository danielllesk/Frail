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
            successExplanation: "Jupiter-like planets intercept debris that would otherwise devastate inner worlds. Remove them — and the inner system never stabilises."
        ),
        MysteryUniverse(
            id: 3,
            clues: [
                "Planetary atmospheres were stripped away in violent bursts of radiation.",
                "The star's surface is extremely turbulent, with massive loops of plasma.",
                "Habitable zones were repeatedly scorched by high-energy particles."
            ],
            options: ["Star is a Red Dwarf", "Extreme Stellar Flares", "Speed of light too high", "Gravity too low"],
            correctIndex: 0,
            successExplanation: "Red dwarfs are fully convective stars that produce violent, frequent flares. These strip planetary atmospheres and flood habitable zones with radiation — even planets in the right temperature range cannot survive."
        ),
        MysteryUniverse(
            id: 4,
            clues: [
                "Orbits are not circles; they are elongated, crossing each other.",
                "Planets frequently come close to one another, causing gravitational chaos.",
                "Eventually, most planets were either ejected into space or fell into the star."
            ],
            options: ["Too many planets", "High Orbital Eccentricity", "Gravity too weak", "Masses too low"],
            correctIndex: 1,
            successExplanation: "Stable systems require nearly circular, well-spaced orbits. High eccentricity leads to close encounters and eventual system collapse."
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
            explanation: "Gravity too weak. Atmospheres escape. Oceans evaporate."
        ),
        RapidFireRound(
            id: 1,
            gravity: 1.0,
            lightSpeed: 0.5,
            mass: 2.0,
            isPossible: false,
            explanation: "Light speed at half value raises the fine-structure constant, destabilising electron orbitals. Atoms cannot form stable bonds. The mass of the planet is irrelevant — matter itself fails first."
        ),
        RapidFireRound(
            id: 2,
            gravity: 1.2,
            lightSpeed: 1.0,
            mass: 1.5,
            isPossible: true,
            explanation: "Slightly stronger gravity. Denser planets. Possible foundation for life."
        ),
        RapidFireRound(
            id: 3,
            gravity: 5.0,
            lightSpeed: 1.0,
            mass: 0.8,
            isPossible: false,
            explanation: "Extreme gravity would crush even the simplest structures."
        ),
        RapidFireRound(
            id: 4,
            gravity: 1.0,
            lightSpeed: 1.5,
            mass: 5.0,
            isPossible: false,
            explanation: "A planet of 5 Earth masses retains a thick gas envelope during formation. No solid surface. No ocean. No foundation for life. The light speed deviation compounds this — atomic bonds are more energetic and less stable."
        ),
        RapidFireRound(
            id: 5,
            gravity: 0.8,
            lightSpeed: 1.2,
            mass: 1.0,
            isPossible: true,
            explanation: "A lighter touch and faster light still permits stable complexity."
        )
    ]
}
