//
//  GravityView.swift
//  Frail
//
//  Chapter 1 — Gravity: The Architect
//  Phase-based story lesson. The universe is 1 second old.
//

import SwiftUI

struct GravityView: View {
    let onComplete: () -> Void
    @EnvironmentObject var nova: NovaController
    
    // MARK: - Phase state
    // 0: Entry (cloud, narration)
    // 1: Low gravity (slider appears, user pulls it down)
    // 2: High gravity (user pushes slider way up)
    // 3: Right gravity (user finds ~1x)
    // 4: Starfield bloom
    // 5: Closing
    @State private var phase = 0
    
    @State private var gravityDisplay: Double = 0.5 // 0x–5x (what user sees)
    @State private var showSlider = false
    @State private var showContinue = false
    @State private var novaText = ""
    @State private var showNovaBubble = false
    @State private var showStarfield = false
    @State private var cloudOpacity: Double = 0
    @State private var chapterLabel = ""
    @State private var entryDone = false
    @State private var phaseTriggered = false  // prevents re-triggering per phase
    @State private var sequenceTask: Task<Void, Never>? = nil
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // ── Solid dark background (hides LearnContainer's StarFieldView) ──
                Color.frailBackground
                    .ignoresSafeArea()
                
                // ── Particle cloud ──
                ParticleCloudView(
                    gravityValue: gravityDisplay,
                    showStars: showStarfield
                )
                .opacity(cloudOpacity)
                
                // ── Chapter label ──
                if !chapterLabel.isEmpty {
                    VStack(spacing: 4) {
                        Text("Chapter 1")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.frailMutedText)
                            .tracking(2)
                        Text("GRAVITY")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.frailPrimaryText)
                            .tracking(3)
                    }
                    .position(x: geo.size.width / 2, y: 60)
                    .transition(.opacity)
                }
                
                // ── Bottom: Nova bubble + Slider + Continue ──
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Nova speech bubble
                    if showNovaBubble {
                        HStack(alignment: .top, spacing: 8) {
                            // Nova slot
                            Color.clear
                                .frame(width: 48, height: 48)
                                .background(
                                    GeometryReader { slotGeo in
                                        Color.clear.preference(
                                            key: NovaSlotPreferenceKey.self,
                                            value: CGPoint(
                                                x: slotGeo.frame(in: .named("appRoot")).midX,
                                                y: slotGeo.frame(in: .named("appRoot")).midY
                                            )
                                        )
                                    }
                                )
                            
                            Text(novaText)
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundColor(.frailPrimaryText)
                                .lineSpacing(4)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.frailMentorBg)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.frailMentorBorder, lineWidth: 1)
                                        )
                                )
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .transition(.opacity.combined(with: .offset(y: 20)))
                        .onPreferenceChange(NovaSlotPreferenceKey.self) { pos in
                            if pos != .zero {
                                nova.flyTo(x: pos.x, y: pos.y, size: 48, state: .speaking)
                            }
                        }
                    }
                    
                    // Gravity slider
                    if showSlider {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Gravity")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.frailMutedText)
                                Spacer()
                                Text(String(format: "%.1fx", gravityDisplay))
                                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                                    .foregroundColor(.frailGold)
                            }
                            
                            Slider(value: $gravityDisplay, in: 0.0...5.0, step: 0.1)
                                .tint(.frailAccent)
                                .onChange(of: gravityDisplay) { newValue in
                                    HapticEngine.shared.playGravityIntensity(multiplier: newValue)
                                    checkSliderPhaseAdvance(newValue)
                                }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .transition(.opacity.combined(with: .offset(y: 20)))
                    }
                    
                    // Continue button
                    if showContinue {
                        Button(action: advancePhase) {
                            Text("Continue")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.frailBackground)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color.frailAccent)
                                )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .transition(.opacity.combined(with: .offset(y: 20)))
                    }
                    
                    Spacer().frame(height: 40)
                }
            }
            .task {
                if !entryDone {
                    entryDone = true
                    await beginPhase0()
                }
            }
            .onDisappear {
                sequenceTask?.cancel()
                sequenceTask = nil
            }
        }
    }
    
    // MARK: - Phase logic
    
    private func beginPhase0() async {
        phase = 0
        gravityDisplay = 0.5
        
        // t=0.3s — Fade in cloud
        try? await Task.sleep(nanoseconds: 300_000_000)
        withAnimation(.easeIn(duration: 1.0)) {
            cloudOpacity = 1.0
            chapterLabel = "Gravity"
        }
        
        // t=1.0s — Nova speaks
        try? await Task.sleep(nanoseconds: 700_000_000)
        showNova(NovaCopy.Gravity.entry)
        
        // t=2.5s — Show continue
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showContinue = true
        }
    }
    
    private func advancePhase() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showContinue = false
        }
        
        phase += 1
        phaseTriggered = false
        
        switch phase {
        case 1:
            // LOW GRAVITY — show slider, auto-set near zero
            showNova(NovaCopy.Gravity.lowGravityPrompt)
            
            sequenceTask = Task {
                try? await Task.sleep(nanoseconds: 500_000_000)
                guard !Task.isCancelled else { return }
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showSlider = true
                }
                // Programmatic change — don't trigger advance
                phaseTriggered = true 
                gravityDisplay = 0.1
                try? await Task.sleep(nanoseconds: 100_000_000)
                phaseTriggered = false
            }
            
        case 2:
            // HIGH GRAVITY — prompt to push it way up
            showNova(NovaCopy.Gravity.highGravityPrompt)
            phaseTriggered = true
            gravityDisplay = 4.5
            Task {
                try? await Task.sleep(nanoseconds: 100_000_000)
                phaseTriggered = false
            }
            
        case 3:
            // RIGHT GRAVITY — find ~1x
            showNova(NovaCopy.Gravity.rightGravityPrompt)
            
        case 4:
            // STARFIELD BLOOM
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showSlider = false
            }
            
            showStarfield = true
            showNova(NovaCopy.Gravity.starfield)
            
            sequenceTask = Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                guard !Task.isCancelled else { return }
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showContinue = true
                }
            }
            
        case 5:
            // CLOSING
            showNova(NovaCopy.Gravity.closing)
            
            sequenceTask = Task {
                try? await Task.sleep(nanoseconds: 2_500_000_000)
                guard !Task.isCancelled else { return }
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showContinue = true
                }
            }
            
        default:
            onComplete()
        }
    }
    
    // MARK: - Slider-driven phase advances
    
    private func checkSliderPhaseAdvance(_ value: Double) {
        guard !phaseTriggered else { return }
        
        // Phase 1: scatter at low gravity (< 0.3x)
        if phase == 1 && value < 0.3 {
            phaseTriggered = true
            showNova(NovaCopy.Gravity.lowGravity)
            showContinueAfterDelay()
        }
        
        // Phase 2: high gravity effects (> 3.5x)
        if phase == 2 && value > 3.5 {
            phaseTriggered = true
            showNova(NovaCopy.Gravity.highGravity)
            showContinueAfterDelay()
        }
        
        // Phase 3: right gravity found (exactly ~1.0x)
        if phase == 3 && value >= 0.9 && value <= 1.1 {
            phaseTriggered = true
            showNova(NovaCopy.Gravity.rightGravity)
            showContinueAfterDelay()
        }
    }
    
    // MARK: - Helpers
    
    private func showContinueAfterDelay() {
        sequenceTask = Task {
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            guard !Task.isCancelled else { return }
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showContinue = true
            }
        }
    }
    
    private func showNova(_ text: String) {
        novaText = text
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showNovaBubble = true
        }
        HapticEngine.shared.playNovaSpeak()
    }
}
