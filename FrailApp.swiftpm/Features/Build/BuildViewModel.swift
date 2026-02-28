//
//  BuildViewModel.swift
//  Frail
//
//  State and logic for the Build section.
//

import SwiftUI
import SceneKit

@MainActor
final class BuildViewModel: ObservableObject {
    
    // MARK: - App State
    @Published var universeName: String = "Untitled Universe"
    @Published var zoomScale: CGFloat = 1.0
    
    // MARK: - Universe Constants
    @Published var gravity: Double = 1.0
    @Published var lightSpeed: Double = 1.0
    @Published var starType: PhysicsConstants.StarType = .yellowSun {
        didSet {
            // Reset to clean slate on star change
            resetSliders()
            updateScore()
        }
    }
    
    // MARK: - Planet Properties
    @Published var planets: [Planet] = (0..<3).map { i in
        Planet(id: i, mass: 1.0, orbitalRadius: 1.0)
    }
    
    // MARK: - Onboarding
    @Published var showOnboarding: Bool = true
    
    // MARK: - App State
    @Published var stabilityScore: Double = 0.0
    @Published var showVerdict: Bool = false
    @Published var selectedCategory: BuildCategory = .constants
    
    enum BuildCategory: String, CaseIterable, Identifiable {
        case constants = "Physics"
        case planets = "Planets"
        var id: String { rawValue }
    }
    
    init() {
        resetSliders()
        updateScore()
    }
    
    private func resetSliders() {
        gravity = PhysicsConstants.Universal.gravityRange.lowerBound
        lightSpeed = PhysicsConstants.Universal.lightSpeedRange.lowerBound
        
        var newPlanets = planets
        for i in 0..<newPlanets.count {
            newPlanets[i].mass = PhysicsConstants.Planets.massRange.lowerBound
            newPlanets[i].orbitalRadius = PhysicsConstants.Planets.orbitRange.lowerBound
        }
        planets = newPlanets
        
        zoomScale = 0.5
    }
    
    // MARK: - Actions
    
    func updateScore() {
        let state = StabilityEngine.UniverseState(
            gravity: gravity,
            lightSpeed: lightSpeed,
            starType: starType,
            planetMasses: planets.map({ $0.mass }),
            planetOrbits: planets.map({ $0.orbitalRadius })
        )
        
        withAnimation(.easeInOut(duration: 0.4)) {
            stabilityScore = StabilityEngine.calculateStability(for: state)
        }
    }
    
    func simulate() {
        updateScore()
        withAnimation(.spring()) {
            showVerdict = true
        }
        // Haptics
        if stabilityScore > 80 {
            HapticEngine.shared.playSuccess()
        } else {
            HapticEngine.shared.playWarning()
        }
    }
    
    func showOptimal() {
        let config = starType.optimalConfig
        
        withAnimation(.easeInOut(duration: 1.5)) {
            gravity = config.gravity
            lightSpeed = config.lightSpeed
            
            var newPlanets = planets
            for i in 0..<newPlanets.count {
                if i < config.masses.count {
                    newPlanets[i].mass = config.masses[i]
                }
                if i < config.orbits.count {
                    newPlanets[i].orbitalRadius = config.orbits[i]
                }
            }
            planets = newPlanets
        }
        
        // Delay score update to match visual arrival
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.updateScore()
        }
    }
    
    func dismissOnboarding() {
        withAnimation {
            showOnboarding = false
        }
    }
    
    var failureReason: String {
        let state = StabilityEngine.UniverseState(
            gravity: gravity,
            lightSpeed: lightSpeed,
            starType: starType,
            planetMasses: planets.map({ $0.mass }),
            planetOrbits: planets.map({ $0.orbitalRadius })
        )
        return StabilityEngine.getFailureReason(for: state, score: stabilityScore)
    }
}
