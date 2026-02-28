//
//  ChallengeViewModel.swift
//  Frail
//
//  Logic for Dead Universe and Rapid Fire modes.
//

import SwiftUI

@MainActor
final class ChallengeViewModel: ObservableObject {
    
    // MARK: - Navigation
    @Published var selectedMode: ChallengeMode = .deadUniverse
    
    enum ChallengeMode: String, CaseIterable, Identifiable {
        case deadUniverse = "Dead Universe"
        case rapidFire = "Rapid Fire"
        var id: String { rawValue }
    }
    
    // MARK: - Dead Universe State
    @Published var currentMysteryIndex = 0
    @Published var revealedCluesCount = 1
    @Published var showResultOverlay = false
    @Published var isCorrect = false
    
    var currentMystery: MysteryUniverse {
        MysteryData.mysteries[currentMysteryIndex]
    }
    
    func nextClue() {
        if revealedCluesCount < currentMystery.clues.count {
            withAnimation(.spring()) {
                revealedCluesCount += 1
            }
        }
    }
    
    func checkAnswer(_ index: Int) {
        isCorrect = (index == currentMystery.correctIndex)
        withAnimation(.spring()) {
            showResultOverlay = true
        }
    }
    
    func nextMystery() {
        showResultOverlay = false
        if currentMysteryIndex < MysteryData.mysteries.count - 1 {
            currentMysteryIndex += 1
            revealedCluesCount = 1
        } else {
            // Loop or finish
            currentMysteryIndex = 0
            revealedCluesCount = 1
        }
    }
    
    // MARK: - Rapid Fire State
    @Published var currentRoundIndex = 0
    @Published var rapidFireScore = 0
    @Published var showRapidResult = false
    @Published var rapidCorrect = false
    @Published var showFinalScore = false
    
    var currentRound: RapidFireRound {
        RapidFireData.rounds[currentRoundIndex]
    }
    
    func judge(possible: Bool) {
        rapidCorrect = (possible == currentRound.isPossible)
        if rapidCorrect { rapidFireScore += 1 }
        
        withAnimation(.spring()) {
            showRapidResult = true
        }
    }
    
    func nextRound() {
        showRapidResult = false
        if currentRoundIndex < RapidFireData.rounds.count - 1 {
            currentRoundIndex += 1
        } else {
            showFinalScore = true
        }
    }
    
    func resetRapidFire() {
        currentRoundIndex = 0
        rapidFireScore = 0
        showFinalScore = false
        showRapidResult = false
    }
}
