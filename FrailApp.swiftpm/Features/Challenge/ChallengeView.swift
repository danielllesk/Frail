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
                            .padding(12)
                            .background(Circle().fill(Color.frailMentorBg.opacity(0.4)))
                    }
                    Spacer()
                    
                    Picker("Mode", selection: $vm.selectedMode) {
                        ForEach(ChallengeViewModel.ChallengeMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 220)
                    .padding(4)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.2)))
                    
                    Spacer()
                    
                    // Score / Streak Indicator
                    HStack(spacing: 8) {
                        if vm.selectedMode == .rapidFire {
                            Text("STREAK")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.frailMutedText)
                            Text("\(vm.streak)")
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundColor(.frailGold)
                        } else {
                            Text("SOLVED")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.frailMutedText)
                            Text("\(vm.universesDiagnosed)")
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundColor(.frailEmerald)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.frailMentorBg.opacity(0.4)))
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                if vm.selectedMode == .deadUniverse {
                    deadUniverseView
                        .transition(.opacity)
                } else {
                    rapidFireView
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            
            // Result Overlays
            if vm.showResultOverlay {
                ChallengeResultOverlay(
                    isCorrect: vm.isCorrect,
                    explanation: vm.currentMystery.successExplanation,
                    buttonLabel: vm.currentMysteryIndex < MysteryData.mysteries.count - 1 ? "Next Mystery" : "Return to Start",
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
                    highStreak: vm.highStreak,
                    onReset: { vm.resetRapidFire() }
                )
            }
        }
        .onPreferenceChange(NovaSlotPreferenceKey.self) { pos in
            if pos != .zero {
                let size: CGFloat = 80
                let state: NovaState
                if vm.showResultOverlay || vm.showRapidResult || vm.showFinalScore {
                    state = vm.isCorrect || vm.rapidCorrect ? .happy : .idle
                } else if vm.deadUniversePhase == .intro && vm.selectedMode == .deadUniverse {
                    state = .speaking
                } else {
                    state = .idle
                }
                nova.flyTo(x: pos.x, y: pos.y, size: size, state: state)
            }
        }
        .animation(.spring(), value: vm.selectedMode)
        .onAppear {
            if vm.selectedMode == .deadUniverse {
                vm.startDeadUniverse()
            } else {
                nova.flyTo(x: 300, y: 150, state: .idle)
            }
        }
        .onChange(of: vm.selectedMode) { mode in
            if mode == .deadUniverse {
                vm.startDeadUniverse()
            }
        }
    }
    
    // MARK: - Dead Universe
    
    private var deadUniverseView: some View {
        ZStack {
            // Background desaturation for "Dead" feel
            Color.black.opacity(0.4).ignoresSafeArea()
            
            if vm.deadUniversePhase == .intro {
                deadUniverseIntroView
                    .transition(.opacity)
            } else {
                deadUniverseCluesView
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    private var deadUniverseIntroView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Nova Slot (Center-ish for Intro)
            Color.clear
                .frame(width: 120, height: 120)
                .overlay(
                    GeometryReader { slotGeo in
                        Color.clear.preference(
                            key: NovaSlotPreferenceKey.self,
                            value: slotGeo.frame(in: .named("appRoot")).center
                        )
                    }
                )
            
            TypewriterText(text: "You have come across a dead universe.\nHeres what I know...", speed: 0.04)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { vm.transitionToClues() }) {
                Text("Investigate Clues")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 40)
                    .background(Capsule().fill(Color.white))
            }
            .padding(.top, 20)
            
            Spacer()
        }
    }
    
    private var deadUniverseCluesView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                // Nova Column (Left)
                VStack {
                    Spacer()
                    Color.clear
                        .frame(width: 80, height: 80)
                        .overlay(
                            GeometryReader { slotGeo in
                                Color.clear.preference(
                                    key: NovaSlotPreferenceKey.self,
                                    value: slotGeo.frame(in: .named("appRoot")).center
                                )
                            }
                        )
                    Spacer()
                }
                .frame(width: 100)
                .padding(.leading, 80)
                
                // Narrative Column (Centered)
                VStack(alignment: .leading, spacing: 32) {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("MYSTERY #\(vm.currentMysteryIndex + 1)")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.frailGold)
                            .tracking(4)
                        
                        Text("DIAGNOSTIC DATA")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.frailMutedText)
                    }
                    
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(0..<vm.revealedCluesCount, id: \.self) { i in
                            HStack(alignment: .top, spacing: 16) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 6))
                                    .foregroundColor(.frailGold)
                                    .padding(.top, 14)
                                
                                TypewriterText(text: vm.currentMystery.clues[i], speed: 0.02)
                                    .font(.system(size: 26, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .lineSpacing(6)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .transition(.move(edge: .leading).combined(with: .opacity))
                        }
                    }
                    
                    if vm.revealedCluesCount < vm.currentMystery.clues.count {
                        Button(action: { vm.nextClue() }) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Request Further Detail")
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.frailAccent)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 24)
                            .background(Capsule().stroke(Color.frailAccent, lineWidth: 2))
                        }
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: 700)
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            // Diagnosis Bars (Bottom Bar)
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("FINAL DIAGNOSIS")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.frailMutedText)
                        .tracking(3)
                    Spacer()
                    Text("\(vm.revealedCluesCount)/\(vm.currentMystery.clues.count) CLUES REVEALED")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.frailGold)
                }
                .padding(.horizontal, 4)
                
                VStack(spacing: 12) {
                    ForEach(0..<vm.currentMystery.options.count, id: \.self) { i in
                        DiagnosisBar(
                            title: vm.currentMystery.options[i],
                            index: i + 1,
                            action: { vm.checkAnswer(i) }
                        )
                    }
                }
            }
            .padding(32)
            .background(Color.black.opacity(0.4).ignoresSafeArea())
        }
    }
    
    // MARK: - Rapid Fire
    
    private var rapidFireView: some View {
        VStack(spacing: 0) {
            Spacer()
            
            HStack(spacing: 0) {
                // Nova Column (Left)
                VStack {
                    Spacer()
                    Color.clear
                        .frame(width: 80, height: 80)
                        .overlay(
                            GeometryReader { slotGeo in
                                Color.clear.preference(
                                    key: NovaSlotPreferenceKey.self,
                                    value: slotGeo.frame(in: .named("appRoot")).center
                                )
                            }
                        )
                    Spacer()
                }
                .frame(width: 100)
                .padding(.leading, 60)
                
                VStack(spacing: 24) {
                    HStack {
                        Text("ROUND \(vm.currentRoundIndex + 1)")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.frailGold)
                            .tracking(3)
                        Spacer()
                        Text("\(RapidFireData.rounds.count - vm.currentRoundIndex) REMAINING")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.frailMutedText)
                    }
                    
                    VStack(spacing: 20) {
                        ConstantIndicator(label: "Gravity", value: String(format: "%.1fx", vm.currentRound.gravity), icon: "arrow.down.to.line.compact")
                        ConstantIndicator(label: "Light Speed", value: String(format: "%.1fc", vm.currentRound.lightSpeed), icon: "bolt.fill")
                        ConstantIndicator(label: "Typical Mass", value: String(format: "%.1f M⊕", vm.currentRound.mass), icon: "circle.circle.fill")
                    }
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.frailMentorBg.opacity(0.7))
                            .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.frailMentorBorder, lineWidth: 1))
                    )
                    .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 10)
                }
                .padding(.trailing, 40)
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            VStack(spacing: 20) {
                Text("COULD COMPLEXITY EMERGE?")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.frailMutedText)
                    .tracking(1)
                
                HStack(spacing: 16) {
                    DecisionButton(label: "POSSIBLE", color: .frailEmerald, icon: "checkmark.circle.fill", action: { vm.judge(possible: true) })
                    DecisionButton(label: "FRAGILE", color: .frailCrimson, icon: "xmark.circle.fill", action: { vm.judge(possible: false) })
                }
            }
            .padding(32)
            .background(Color.black.opacity(0.3).ignoresSafeArea())
        }
    }
}

// MARK: - Helpers

struct TypewriterText: View {
    let text: String
    var speed: Double = 0.02
    @State private var displayedText: String = ""
    @State private var task: Task<Void, Never>?
    
    var body: some View {
        Text(displayedText)
            .onAppear {
                startTyping()
            }
            .onChange(of: text) { _ in
                startTyping()
            }
            .onDisappear {
                task?.cancel()
            }
    }
    
    private func startTyping() {
        task?.cancel()
        displayedText = ""
        task = Task {
            for char in text {
                if Task.isCancelled { break }
                displayedText.append(char)
                try? await Task.sleep(nanoseconds: UInt64(speed * 1_000_000_000))
            }
        }
    }
}

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

struct DiagnosisBar: View {
    let title: String
    let index: Int
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(String(format: "%02d", index))
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.frailGold)
                    .frame(width: 24, alignment: .leading)
                
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.frailGold.opacity(0.8))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.frailMentorBg.opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Subcomponents

struct ConstantIndicator: View {
    let label: String
    let value: String
    let icon: String
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.frailGold)
                .frame(width: 24)
            Text(label.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.frailMutedText)
                .tracking(1)
            Spacer()
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundColor(.frailPrimaryText)
        }
    }
}

struct DecisionButton: View {
    let label: String
    let color: Color
    let icon: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(label)
                    .font(.system(size: 14, weight: .black, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .background(RoundedRectangle(cornerRadius: 20).fill(color.opacity(0.8)))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
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
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                VStack(spacing: 24) {
                    HStack(spacing: 24) {
                        // Nova Slot (Left of symbol)
                        Color.clear
                            .frame(width: 80, height: 80)
                            .overlay(
                                GeometryReader { slotGeo in
                                    Color.clear.preference(
                                        key: NovaSlotPreferenceKey.self,
                                        value: slotGeo.frame(in: .named("appRoot")).center
                                    )
                                }
                            )
                        
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .font(.system(size: 72))
                            .foregroundColor(isCorrect ? .frailEmerald : .frailAmber)
                            .symbolRenderingMode(.hierarchical)
                    }
                    
                    Text(isCorrect ? "INSIGHT REVEALED" : "MISCALCULATION")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(3)
                }
                
                Text(explanation)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(.frailPrimaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
                
                Button(action: onContinue) {
                    Text(buttonLabel)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 48)
                        .background(Capsule().fill(Color.white))
                        .shadow(color: Color.white.opacity(0.3), radius: 10, x: 0, y: 5)
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.frailMentorBg)
                    .overlay(RoundedRectangle(cornerRadius: 32).stroke(Color.white.opacity(0.1), lineWidth: 1))
            )
            .padding(24)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
}

struct FinalScoreOverlay: View {
    let score: Int
    let total: Int
    let highStreak: Int
    let onReset: () -> Void
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("SIMULATION COMPLETE")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.frailGold)
                    .tracking(5)
                
                VStack(spacing: 24) {
                    HStack(spacing: 24) {
                        // Nova Slot (Left of score)
                        Color.clear
                            .frame(width: 80, height: 80)
                            .overlay(
                                GeometryReader { slotGeo in
                                    Color.clear.preference(
                                        key: NovaSlotPreferenceKey.self,
                                        value: slotGeo.frame(in: .named("appRoot")).center
                                    )
                                }
                            )
                        
                        Text("\(score)")
                            .font(.system(size: 84, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    Text("UNIVERSES DIAGNOSED")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.frailMutedText)
                }
                
                HStack(spacing: 40) {
                    VStack(spacing: 4) {
                        Text("\(total)")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(.frailPrimaryText)
                        Text("TOTAL")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.frailMutedText)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(highStreak)")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(.frailGold)
                        Text("BEST STREAK")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.frailMutedText)
                    }
                }
                
                Text(score == total ? "Your understanding of universal stability is remarkable. You see through the complexity." : "Fragility is the default state of existence. Mastery is a slow accumulation.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.frailPrimaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Button(action: onReset) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Refresh Simulation")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.vertical, 18)
                    .padding(.horizontal, 48)
                    .background(Capsule().fill(Color.white))
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.frailMentorBg)
                    .overlay(RoundedRectangle(cornerRadius: 32).stroke(Color.white.opacity(0.1), lineWidth: 1))
            )
            .padding(24)
        }
    }
}
