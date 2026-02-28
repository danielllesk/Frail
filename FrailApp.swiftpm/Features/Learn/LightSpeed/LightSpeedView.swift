//
//  LightSpeedView.swift
//  Frail
//
//  Chapter 2 — Light Speed: The Weaver
//  Phase-based story lesson. Zooming into the atomic structure of matter.
//

import SwiftUI

struct LightSpeedView: View {
    let onComplete: () -> Void
    @EnvironmentObject var nova: NovaController
    
    // MARK: - Phase state
    // 0: Zoom in (from starfield to atom)
    // 1: Normal (intro atom)
    // 2: Low light speed (slider, dissolve)
    // 3: High light speed (slider, compress)
    // 4: Right light speed (find 1x)
    // 5: Dying Star (zoom out to red giant)
    // 6: Supernova (closing)
    @State private var phase = 0
    
    @State private var lightSpeed: Double = 1.0
    @State private var showSlider = false
    @State private var showContinue = false
    @State private var novaText = ""
    @State private var showNovaBubble = false
    @State private var atomOpacity: Double = 0
    @State private var starOpacity: Double = 1.0
    @State private var starScale: CGFloat = 1.0
    @State private var chapterLabel = ""
    @State private var entryDone = false
    @State private var phaseTriggered = false
    @State private var supernovaTriggered = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1. Solid background - hides the container's StarFieldView completely
                Color.frailBackground.ignoresSafeArea()
                
                // 2. Star field/Star view (Phases 0, 5, 6)
                // Layered below everything else
                ZStack {
                    // Ambient stars
                    StarFieldView().opacity(min(1.0, starOpacity))
                    
                    // The "Zoom" star - locked in center for stable scaling
                    ZStack {
                        // Secondary outer flare
                        Circle()
                            .fill(RadialGradient(
                                gradient: Gradient(colors: [
                                    .white.opacity(0.4),
                                    .frailAccent.opacity(0.2),
                                    .clear
                                ]),
                                center: .center, startRadius: 0, endRadius: 30
                            ))
                            .scaleEffect(starScale * 1.2)
                        
                        // Core star
                        Circle()
                            .fill(RadialGradient(
                                gradient: Gradient(colors: [
                                    phase >= 5 ? .red : .white, 
                                    phase >= 5 ? .orange.opacity(0.8) : .frailAccent.opacity(0.6),
                                    .clear
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 20
                            ))
                            .scaleEffect(starScale)
                    }
                    .frame(width: 100, height: 100) // LOCK FRAME for stable scaling
                    .opacity(starOpacity)
                }
                .opacity(starOpacity) // Let starOpacity drive everything, avoid rigid masks
                
                // 3. Atom view (Phases 1-4)
                if atomOpacity > 0 {
                    AtomView(lightSpeed: lightSpeed)
                        .opacity(atomOpacity)
                        .scaleEffect(phase >= 5 ? 0.2 : 1.0)
                }
                
                // 3. Supernova (Phase 6)
                if supernovaTriggered {
                    SupernovaView()
                }
                
                // Overlay for chapter label
                if !chapterLabel.isEmpty {
                    VStack(spacing: 4) {
                        Text("Chapter 2")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.frailMutedText)
                            .tracking(2)
                        Text("LIGHT SPEED")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.frailPrimaryText)
                            .tracking(3)
                    }
                    .position(x: geo.size.width / 2, y: 60)
                    .transition(.opacity)
                }
                
                // Bottom: Nova bubble + Slider + Continue
                VStack(spacing: 0) {
                    Spacer()
                    
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
                    
                    if showSlider {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Speed of Light")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.frailMutedText)
                                Spacer()
                                Text(String(format: "%.1fc", lightSpeed))
                                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                                    .foregroundColor(.frailGold)
                            }
                            
                            Slider(value: $lightSpeed, in: 0.1...5.0, step: 0.1)
                                .tint(.frailAccent)
                                .onChange(of: lightSpeed) { newValue in
                                    HapticEngine.shared.playSliderMove(intensity: Float(newValue / 5.0))
                                    checkSliderPhaseAdvance(newValue)
                                }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .transition(.opacity.combined(with: .offset(y: 20)))
                    }
                    
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
            .onAppear {
                guard !entryDone else { return }
                entryDone = true
                beginPhase0()
            }
        }
    }
    
    // MARK: - Phase Logic
    
    private func beginPhase0() {
        phase = 0
        withAnimation(.easeIn(duration: 0.6)) {
            chapterLabel = "Light Speed"
        }
        
        // Ensure initial state
        starScale = 0.5
        starOpacity = 1.0
        atomOpacity = 0.0
        
        // 1. Zoom in animation — Aggressive tunnel effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 2.0)) {
                // High scale + fade for the rush feel
                starScale = 80.0 
                starOpacity = 0.0
            }
            
            // Fading atom in midway through (t=1.0) creates the arrival
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeIn(duration: 1.2)) {
                    atomOpacity = 1.0
                }
            }
            
            // 2. First Nova bubble
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                showNova(NovaCopy.LightSpeed.entry)
            }
            
            scheduleContinue(after: 5.0)
        }
    }
    
    // MARK: - Actions
    
    private func showNova(_ text: String) {
        if showNovaBubble {
            // Fade out current bubble
            withAnimation(.easeOut(duration: 0.2)) {
                showNovaBubble = false
            }
            
            // Wait, swap text, then fade back in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                novaText = text
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showNovaBubble = true
                }
                HapticEngine.shared.playNovaSpeak()
            }
        } else {
            novaText = text
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showNovaBubble = true
            }
            HapticEngine.shared.playNovaSpeak()
        }
    }
    
    private func scheduleContinue(after delay: Double = 2.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if self.phase < 7 { // Simple guard for lesson end
                withAnimation {
                    showContinue = true
                }
            }
        }
    }
    
    private func advancePhase() {
        phaseTriggered = false
        withAnimation { showContinue = false }
        phase += 1
        
        switch phase {
        case 1:
            // Intro to the Carbon atom
            showNova(NovaCopy.LightSpeed.normalAtom)
            withAnimation(.spring()) {
                lightSpeed = 1.0
                showSlider = false // Keep hidden until asked
            }
            scheduleContinue(after: 4.0)
            
        case 2:
            // Low c phase - user asked to interact
            showNova(NovaCopy.LightSpeed.lowLightPrompt)
            withAnimation(.spring()) {
                showSlider = true
            }
            
        case 3:
            // High c phase
            showNova(NovaCopy.LightSpeed.highLightPrompt)
            withAnimation(.spring()) {
                lightSpeed = 1.0 
            }
            
        case 4:
            // Find right c
            showNova(NovaCopy.LightSpeed.rightLightPrompt)
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                lightSpeed = 2.5 
            }
            
        case 5:
            // Scale out to red giant
            withAnimation(.easeInOut(duration: 2.0)) {
                showSlider = false
                starScale = 1.2
                starOpacity = 1.0
                atomOpacity = 0.0
            }
            showNova(NovaCopy.LightSpeed.starfield)
            scheduleContinue(after: 6.0)
            
        case 6:
            // Final closing + Supernova trigger
            withAnimation { starOpacity = 0.0 }
            supernovaTriggered = true
            showNova(NovaCopy.LightSpeed.closing)
            scheduleContinue(after: 5.0)
            
        default:
            onComplete()
        }
    }
    
    private func checkSliderPhaseAdvance(_ value: Double) {
        if phaseTriggered { return }
        
        if phase == 2 && value < 0.4 {
            phaseTriggered = true
            showNova(NovaCopy.LightSpeed.lowLight)
            scheduleContinue(after: 3.5)
        }
        
        if phase == 3 && value > 4.0 {
            phaseTriggered = true
            showNova(NovaCopy.LightSpeed.highLight)
            scheduleContinue(after: 3.5)
        }
        
        if phase == 4 && value >= 0.9 && value <= 1.1 {
            phaseTriggered = true
            showNova(NovaCopy.LightSpeed.rightLight)
            scheduleContinue(after: 3.0)
        }
    }
}

// MARK: - Supernova Visual

struct SupernovaView: View {
    @State private var flashOpacity: Double = 1.0
    @State private var startTime: Date? = nil
    private let particles: [SupernovaSeed]
    
    struct SupernovaSeed {
        let angle: Double
        let speed: Double
        let size: CGFloat
        let color: Color
    }
    
    init() {
        var p: [SupernovaSeed] = []
        for _ in 0..<150 {
            p.append(SupernovaSeed(
                angle: Double.random(in: 0...(.pi * 2)),
                speed: Double.random(in: 100...400),
                size: CGFloat.random(in: 2...5),
                color: [Color.white, Color.orange, Color.blue, Color.frailAccent].randomElement()!
            ))
        }
        self.particles = p
    }
    
    var body: some View {
        ZStack {
            // Initial flash
            Color.white
                .opacity(flashOpacity)
                .ignoresSafeArea()
                .onAppear {
                    startTime = Date()
                    withAnimation(.easeOut(duration: 1.5)) {
                        flashOpacity = 0
                    }
                }
            
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    guard let start = startTime else { return }
                    let elapsed = timeline.date.timeIntervalSince(start)
                    
                    for particle in particles {
                        let distance = particle.speed * elapsed
                        let dx = cos(particle.angle) * distance
                        let dy = sin(particle.angle) * distance
                        
                        let px = (size.width / 2) + dx
                        let py = (size.height / 2) + dy
                        
                        // Fade out over distance
                        let opacity = max(0, 1.0 - (distance / 600))
                        guard opacity > 0 else { continue }
                        
                        let rect = CGRect(x: px - particle.size/2, y: py - particle.size/2, width: particle.size, height: particle.size)
                        context.opacity = opacity
                        context.fill(Circle().path(in: rect), with: .color(particle.color))
                    }
                }
            }
        }
    }
}
