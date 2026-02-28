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
    
    enum DeadUniversePhase {
        case intro
        case clues
        case solving
    }
    
    @Published var deadUniversePhase: DeadUniversePhase = .intro
    @Published var hasSeenDeadUniverseIntro: Bool = false
    
    // MARK: - Dead Universe State
    @Published var currentMysteryIndex = 0
    @Published var revealedCluesCount = 0 // Start at 0 for sequential reveal
    @Published var showResultOverlay = false
    @Published var isCorrect = false
    @Published var universesDiagnosed = 0
    
    var currentMystery: MysteryUniverse {
        MysteryData.mysteries[currentMysteryIndex]
    }
    
    func startDeadUniverse() {
        if hasSeenDeadUniverseIntro {
            deadUniversePhase = .clues
            revealedCluesCount = 1
        } else {
            deadUniversePhase = .intro
            revealedCluesCount = 0
        }
    }
    
    func transitionToClues() {
        hasSeenDeadUniverseIntro = true
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            deadUniversePhase = .clues
            revealedCluesCount = 1
        }
    }
    
    func nextClue() {
        if revealedCluesCount < currentMystery.clues.count {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                revealedCluesCount += 1
            }
            HapticEngine.shared.playSuccess()
        }
    }
    
    func checkAnswer(_ index: Int) {
        let correct = (index == currentMystery.correctIndex)
        isCorrect = correct
        
        if correct {
            universesDiagnosed += 1
            HapticEngine.shared.playSuccess()
        } else {
            HapticEngine.shared.playWarning()
        }
        
        withAnimation(.spring()) {
            showResultOverlay = true
        }
    }
    
    func nextMystery() {
        showResultOverlay = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if self.currentMysteryIndex < MysteryData.mysteries.count - 1 {
                self.currentMysteryIndex += 1
            } else {
                self.currentMysteryIndex = 0
            }
            self.startDeadUniverse()
        }
    }
    
    // MARK: - Rapid Fire State
    @Published var currentRoundIndex = 0
    @Published var rapidFireScore = 0
    @Published var streak = 0
    @Published var highStreak = 0
    @Published var showRapidResult = false
    @Published var rapidCorrect = false
    @Published var showFinalScore = false
    
    var currentRound: RapidFireRound {
        RapidFireData.rounds[currentRoundIndex]
    }
    
    func judge(possible: Bool) {
        let correct = (possible == currentRound.isPossible)
        rapidCorrect = correct
        
        if correct {
            rapidFireScore += 1
            streak += 1
            highStreak = max(highStreak, streak)
            HapticEngine.shared.playSuccess()
        } else {
            streak = 0
            HapticEngine.shared.playWarning()
        }
        
        withAnimation(.spring()) {
            showRapidResult = true
        }
    }
    
    func nextRound() {
        showRapidResult = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if self.currentRoundIndex < RapidFireData.rounds.count - 1 {
                self.currentRoundIndex += 1
            } else {
                self.showFinalScore = true
            }
        }
    }
    
    func resetRapidFire() {
        currentRoundIndex = 0
        rapidFireScore = 0
        streak = 0
        showFinalScore = false
        showRapidResult = false
    }
}
