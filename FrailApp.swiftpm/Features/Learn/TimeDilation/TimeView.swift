//
//  TimeView.swift
//  Frail
//
//  Chapter 3 — Time: The Stage
//  Phase-based story lesson on relativity and the Twin Paradox.
//

import SwiftUI

struct TimeView: View {
    let onComplete: () -> Void
    @EnvironmentObject var nova: NovaController
    
    // MARK: - Phase State
    @State private var phase = 0
    @State private var velocity: Double = 0.0
    
    // Physical Constant: Time Dilation Factor (1/gamma)
    // At v=0, dilation = 1.0 (same as Bob)
    // At v=c, dilation -> 0 (time stops)
    @State private var aliceTimeDilation: Double = 1.0
    
    // Aging State (In Years)
    @State private var bobAge: Double = 20.0  
    @State private var aliceAge: Double = 20.0
    
    @State private var showAliceBob = false
    @State private var showSlider = false
    @State private var showContinue = false
    @State private var novaText = ""
    @State private var showNovaBubble = false
    @State private var phaseTriggered = false
    
    @State private var sequenceTask: Task<Void, Never>? = nil
    @State private var novaTask: Task<Void, Never>? = nil
    @State private var entryDone = false
    
    // Control for when the mission clock is "running"
    @State private var isMissionRunning = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // ── Chapter Label ──
                VStack(spacing: 4) {
                    Text("Chapter 3")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.frailMutedText.opacity(0.8))
                        .tracking(2)
                    Text("TIME")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.frailPrimaryText)
                        .tracking(3)
                }
                .position(x: geo.size.width / 2, y: 60)
                
                // ── Centerpiece Clocks ──
                if showAliceBob {
                    HStack(spacing: 80) {
                        // ALICE (LEFT) - The one who slows down
                        ClockView(age: aliceAge, label: "Alice")
                            .transition(.opacity.combined(with: .move(edge: .leading)))
                        
                        // BOB (RIGHT) - The baseline constant
                        ClockView(age: bobAge, label: "Bob")
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                    }
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.42)
                }
                
                // ── Timeline Logic for Aging ──
                TimelineView(.animation) { timeline in
                    Color.clear
                        .onChange(of: timeline.date) { _ in
                            if isMissionRunning {
                                updateAges()
                            }
                        }
                }
                
                // ── Bottom UI Layer ──
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Nova Speech Bubble
                    if showNovaBubble {
                        HStack(alignment: .top, spacing: 8) {
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
                                .frame(maxWidth: 600, alignment: .leading)
                            
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
                    
                    // Velocity Slider
                    if showSlider {
                        VStack(spacing: 12) {
                            HStack {
                                Text("ALICE'S VELOCITY")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(.frailMutedText)
                                    .tracking(1)
                                Spacer()
                                Text("\(Int(velocity * 100))% c")
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .foregroundColor(.frailGold)
                            }
                            
                            Slider(value: $velocity, in: 0.0...0.99, step: 0.01)
                                .tint(.frailAccent)
                                .onChange(of: velocity) { newValue in
                                    updateVelocity(newValue)
                                    checkSliderPhaseAdvance(newValue)
                                }
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 24)
                        .transition(.opacity.combined(with: .offset(y: 20)))
                    }
                    
                    // Continue Button
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
                        .padding(.top, 20)
                        .transition(.opacity.combined(with: .offset(y: 20)))
                    }
                    
                    Spacer().frame(height: 48)
                }
            }
            .onAppear {
                guard !entryDone else { return }
                entryDone = true
                sequenceTask = Task {
                    await beginPhase0()
                }
            }
            .onDisappear {
                sequenceTask?.cancel()
                sequenceTask = nil
                novaTask?.cancel()
                novaTask = nil
            }
        }
    }
    
    // MARK: - Aging Logic
    
    private func updateAges() {
        // Baseline speed: 1 year per real second (so bob goes fast)
        let yearsPerSecond: Double = 0.8
        let dt = 0.016 * yearsPerSecond
        
        // Bob ages at 1x constant speed
        bobAge += dt
        
        // Alice ages at a DILATED rate (always <= bob's rate)
        // aliceAge increases by dt * (1/gamma)
        aliceAge += dt * aliceTimeDilation
    }
    
    // MARK: - Phase Logic
    
    private func beginPhase0() async {
        phase = 0
        nova.hide()
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        guard !Task.isCancelled else { return }
        
        showNova(NovaCopy.Time.entry)
        
        try? await Task.sleep(nanoseconds: 3_500_000_000)
        guard !Task.isCancelled else { return }
        
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
            // SETUP: Alice & Bob reveal
            showNova(NovaCopy.Time.setup)
            
            sequenceTask = Task {
                try? await Task.sleep(nanoseconds: 800_000_000)
                guard !Task.isCancelled else { return }
                
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    showAliceBob = true
                }
                
                try? await Task.sleep(nanoseconds: 3_500_000_000)
                guard !Task.isCancelled else { return }
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showContinue = true
                }
            }
            
        case 2:
            // VELOCITY: Slider appears, aging starts
            showNova(NovaCopy.Time.velocityPrompt)
            isMissionRunning = true 
            
            sequenceTask = Task {
                try? await Task.sleep(nanoseconds: 800_000_000)
                guard !Task.isCancelled else { return }
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showSlider = true
                }
            }
            
        case 3:
            // HIGH VELOCITY: Detailed explanation
            showNova(NovaCopy.Time.highVelocity)
            
            sequenceTask = Task {
                try? await Task.sleep(nanoseconds: 7_000_000_000)
                guard !Task.isCancelled else { return }
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showContinue = true
                }
            }
            
        case 4:
            // RETURN: Prompt to zero slider
            showNova(NovaCopy.Time.reunionPrompt)
            
        case 5:
            // REUNION: The gap realization
            showNova(NovaCopy.Time.reunion)
            
            sequenceTask = Task {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                guard !Task.isCancelled else { return }
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showContinue = true
                }
            }
            
        case 6:
            // CLOSING
            isMissionRunning = false 
            showNova(NovaCopy.Time.closing)
            
            sequenceTask = Task {
                try? await Task.sleep(nanoseconds: 7_000_000_000)
                guard !Task.isCancelled else { return }
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showContinue = true
                }
            }
            
        default:
            onComplete()
        }
    }
    
    private func checkSliderPhaseAdvance(_ v: Double) {
        guard !phaseTriggered else { return }
        
        if phase == 2 && v > 0.94 {
            phaseTriggered = true
            advancePhase() 
        }
        
        if phase == 4 && v < 0.03 {
            phaseTriggered = true
            advancePhase() 
        }
    }
    
    private func updateVelocity(_ v: Double) {
        velocity = v
        
        // Proper time dilation formula:
        // Proper time tau = t * sqrt(1 - v^2/c^2)
        // Here, t is Bob's time. 
        // Our 'aliceTimeDilation' represents the factor by which Alice's clock ticks *slower*.
        // factor = sqrt(1 - v^2)
        let v2 = v * v
        aliceTimeDilation = sqrt(1.0 - v2)
        
        HapticEngine.shared.playTimeDilationPulse(velocity: v)
    }
    
    private func showNova(_ text: String) {
        novaTask?.cancel()
        novaTask = Task {
            if showNovaBubble {
                withAnimation(.easeOut(duration: 0.2)) {
                    showNovaBubble = false
                }
                try? await Task.sleep(nanoseconds: 250_000_000)
                guard !Task.isCancelled else { return }
                
                novaText = text
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showNovaBubble = true
                }
                HapticEngine.shared.playNovaSpeak()
            } else {
                novaText = text
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showNovaBubble = true
                }
                HapticEngine.shared.playNovaSpeak()
            }
        }
    }
}
