//
//  ChallengeView.swift
//  Frail
//

import SwiftUI

struct ChallengeView: View {
    let onBack: () -> Void
    @StateObject private var vm = ChallengeViewModel()
    @EnvironmentObject var nova: NovaController
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.frailPrimaryText)
                    }
                    Spacer()
                    
                    Picker("Mode", selection: $vm.selectedMode) {
                        ForEach(ChallengeViewModel.ChallengeMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 240)
                    
                    Spacer()
                    // Dummy for spacing
                    Color.clear.frame(width: 24, height: 24)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                if vm.selectedMode == .deadUniverse {
                    deadUniverseView
                } else {
                    rapidFireView
                }
            }
            
            // Result Overlays
            if vm.showResultOverlay {
                ChallengeResultOverlay(
                    isCorrect: vm.isCorrect,
                    explanation: vm.currentMystery.successExplanation,
                    buttonLabel: "Next Mystery",
                    onContinue: { vm.nextMystery() }
                )
            }
            
            if vm.showRapidResult {
                ChallengeResultOverlay(
                    isCorrect: vm.rapidCorrect,
                    explanation: vm.currentRound.explanation,
                    buttonLabel: "Next Round",
                    onContinue: { vm.nextRound() }
                )
            }
            
            if vm.showFinalScore {
                FinalScoreOverlay(
                    score: vm.rapidFireScore,
                    total: RapidFireData.rounds.count,
                    onReset: { vm.resetRapidFire() }
                )
            }
        }
        .onAppear {
            nova.flyTo(x: 60, y: 120, state: .idle)
        }
    }
    
    // MARK: - Dead Universe
    
    private var deadUniverseView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 16) {
                Text("MYSTERY #\(vm.currentMysteryIndex + 1)")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.frailGold)
                    .tracking(2)
                
                Text("A collapsed system lies before you. Nova offers these clues:")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.frailMutedText)
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(0..<vm.revealedCluesCount, id: \.self) { i in
                        Text("“\(vm.currentMystery.clues[i])”")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.frailPrimaryText)
                            .padding(.vertical, 8)
                            .transition(.asymmetric(insertion: .move(edge: .leading).combined(with: .opacity), removal: .opacity))
                    }
                }
                
                if vm.revealedCluesCount < vm.currentMystery.clues.count {
                    Button(action: { vm.nextClue() }) {
                        Text("Request Further Clue")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.frailAccent)
                    }
                    .padding(.top, 8)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.frailMentorBg.opacity(0.8))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.frailMentorBorder, lineWidth: 1))
            )
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Answer Options
            VStack(spacing: 12) {
                Text("WHAT KILLED THIS UNIVERSE?")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.frailMutedText)
                    .tracking(1)
                
                ForEach(0..<vm.currentMystery.options.count, id: \.self) { i in
                    Button(action: { vm.checkAnswer(i) }) {
                        Text(vm.currentMystery.options[i])
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.frailPrimaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.frailMentorBg.opacity(0.6))
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.frailMentorBorder, lineWidth: 1))
                            )
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Rapid Fire
    
    private var rapidFireView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("ROUND \(vm.currentRoundIndex + 1) OF \(RapidFireData.rounds.count)")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.frailGold)
                    .tracking(2)
                
                VStack(spacing: 16) {
                    ConstantIndicator(label: "Gravity", value: String(format: "%.1fx", vm.currentRound.gravity))
                    ConstantIndicator(label: "Speed of Light", value: String(format: "%.1fc", vm.currentRound.lightSpeed))
                    ConstantIndicator(label: "Planet Mass", value: String(format: "%.1f M⊕", vm.currentRound.mass))
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.frailMentorBg.opacity(0.8))
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.frailMentorBorder, lineWidth: 1))
                )
            }
            .padding(.horizontal, 24)
            
            Text("COULD LIFE EMERGE HERE?")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.frailPrimaryText)
            
            HStack(spacing: 20) {
                DecisionButton(label: "POSSIBLE", color: .green, action: { vm.judge(possible: true) })
                DecisionButton(label: "IMPOSSIBLE", color: .red, action: { vm.judge(possible: false) })
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
}

// MARK: - Subcomponents

struct ConstantIndicator: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.frailMutedText)
            Spacer()
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.frailPrimaryText)
        }
    }
}

struct DecisionButton: View {
    let label: String
    let color: Color
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(RoundedRectangle(cornerRadius: 16).fill(color.opacity(0.8)))
        }
    }
}

struct ChallengeResultOverlay: View {
    let isCorrect: Bool
    let explanation: String
    let buttonLabel: String
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(isCorrect ? .green : .red)
                
                Text(isCorrect ? "CORRECT" : "INCORRECT")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .tracking(2)
                
                Text(explanation)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.frailPrimaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                Button(action: onContinue) {
                    Text(buttonLabel)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 32)
                        .background(Capsule().fill(Color.white))
                }
            }
            .padding(32)
        }
    }
}

struct FinalScoreOverlay: View {
    let score: Int
    let total: Int
    let onReset: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            
            VStack(spacing: 32) {
                Text("CHALLENGE COMPLETE")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.frailGold)
                    .tracking(4)
                
                VStack(spacing: 8) {
                    Text("\(score) / \(total)")
                        .font(.system(size: 72, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                    Text("UNIVERSES DIAGNOSED")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.frailMutedText)
                }
                
                Text(score == total ? "You understand what the universe requires. That understanding is rare." : "The constants are subtler than they appear. Physics does not negotiate.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.frailPrimaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Button(action: onReset) {
                    Text("Try Again")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 40)
                        .background(Capsule().fill(Color.white))
                }
            }
        }
    }
}
