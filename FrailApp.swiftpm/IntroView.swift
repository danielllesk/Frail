//
//  IntroView.swift
//  Frail
//
//  Cinematic intro — Netflix-style title zoom, orbiting Nova, tap-to-start.
//

import SwiftUI

struct IntroView: View {
    let onFinished: () -> Void
    @EnvironmentObject var nova: NovaController
    
    // MARK: - Letter animation
    @State private var showLetter0 = false
    @State private var showLetter1 = false
    @State private var showLetter2 = false
    @State private var showLetter3 = false
    @State private var showLetter4 = false
    
    // MARK: - Phase animation
    @State private var titleShrunk = false
    @State private var earthVisible = false
    @State private var showTapHint = false
    @State private var titlePulse = false
    @State private var tapHintPulse = false
    @State private var didTap = false
    @State private var showWelcome = false
    @State private var showContinue = false
    @State private var sequenceTask: Task<Void, Never>?
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let earthCX = w / 2
            let earthCY = h * 0.48
            
            ZStack {
                // Background is handled by AppRootView globally
                
                // ── TITLE ──
                titleLetters
                    .scaleEffect(titleShrunk ? 0.4 : 1.0)
                    .opacity(titlePulse ? 0.5 : 1.0)
                    .position(
                        x: w / 2,
                        y: titleShrunk ? h * 0.07 : h * 0.52
                    )
                    .animation(.easeInOut(duration: 1.2), value: titleShrunk)
                
                // ── EARTH ──
                if earthVisible {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.frailAccent.opacity(0.20),
                                        Color.frailAccent.opacity(0.08),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 80,
                                    endRadius: 180
                                )
                            )
                            .frame(width: 600, height: 600)
                            .blur(radius: 12)
                        
                        EarthSceneView()
                            .frame(width: 600, height: 600)
                            .clipShape(Circle())
                    }
                    .position(x: earthCX, y: earthCY)
                    .transition(.opacity)
                }
                
                // Nova is rendered by AppRootView — no local NovaView
                
                // ── Tap hint ──
                if showTapHint && !didTap {
                    Text("Tap anywhere")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.frailMutedText)
                        .tracking(2)
                        .opacity(tapHintPulse ? 0.3 : 1.0)
                        .position(x: w / 2, y: h * 0.93)
                }
                
                // ── Welcome bubble + Continue ──
                if showWelcome {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        // Nova + speech bubble, centered horizontally
                        if showWelcome {
                            HStack(alignment: .top, spacing: 8) {
                                // Nova slot — reports position via preference key
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
                                
                                Text(NovaCopy.Intro.welcome)
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
                            }
                            .transition(.opacity.combined(with: .offset(y: 20)))
                        }
                        
                        if showContinue {
                            Button(action: onFinished) {
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
                            .transition(.opacity.combined(with: .offset(y: 20)))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 60)
                    .onPreferenceChange(NovaSlotPreferenceKey.self) { pos in
                        if pos != .zero {
                            nova.flyTo(x: pos.x, y: pos.y, size: 48, state: .speaking)
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                guard showTapHint && !didTap else { return }
                
                // Hide tap hint
                withAnimation(.easeOut(duration: 0.3)) {
                    showTapHint = false
                }
                
                didTap = true
                
                // Stop orbit — Nova will fly to the speech-bubble slot
                // once the GeometryReader fires.
                nova.stopOrbit()
                
                // Show welcome bubble — Nova will fly to it
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showWelcome = true
                    }
                }
                
                // Show continue button
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showContinue = true
                    }
                }
            }
            .onAppear {
                beginSequence(earthCX: earthCX, earthCY: earthCY)
            }
            .onDisappear {
                sequenceTask?.cancel()
                sequenceTask = nil
            }
            .onChange(of: geo.size) { newSize in
                let cx = newSize.width / 2
                let cy = newSize.height * 0.48
                nova.updateOrbitCenter(cx: cx, cy: cy)
                
                // Backup start: if geometry just settled and we are in orbit phase but not orbiting yet
                if earthVisible && !didTap && !nova.isOrbiting && cx > 0 {
                    nova.orbitAround(cx: cx, cy: cy, radius: 340)
                }
            }
            .onChange(of: earthVisible) { visible in
                // Primary start: trigger orbit as soon as Earth appears
                if visible && !didTap && !nova.isOrbiting {
                    let cx = geo.size.width / 2
                    let cy = geo.size.height * 0.48
                    if cx > 0 {
                        nova.orbitAround(cx: cx, cy: cy, radius: 340)
                    }
                }
            }
        }
    }
    
    // MARK: - Title letters
    
    private var titleLetters: some View {
        HStack(spacing: 4) {
            letterCell("F", visible: showLetter0)
            letterCell("R", visible: showLetter1)
            letterCell("A", visible: showLetter2)
            letterCell("I", visible: showLetter3)
            letterCell("L", visible: showLetter4)
        }
    }
    
    private func letterCell(_ char: String, visible: Bool) -> some View {
        ZStack {
            // Wide bloom
            Text(char)
                .font(.system(size: 150, weight: .heavy, design: .rounded))
                .foregroundColor(.frailAccent.opacity(0.25))
                .blur(radius: 20)
            
            // Tight bloom
            Text(char)
                .font(.system(size: 150, weight: .heavy, design: .rounded))
                .foregroundColor(.white.opacity(0.4))
                .blur(radius: 6)
            
            // Sharp letter
            Text(char)
                .font(.system(size: 150, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color(red: 0.82, green: 0.88, blue: 1.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .frailAccent.opacity(0.7), radius: 10)
                .shadow(color: .frailAccent.opacity(0.35), radius: 25)
        }
        .scaleEffect(visible ? 1.0 : 3.0)
        .opacity(visible ? 1.0 : 0.0)
    }
    
    // MARK: - Animation sequence
    
    private func beginSequence(earthCX: CGFloat, earthCY: CGFloat) {
        sequenceTask = Task { @MainActor in
            // t=0.3s — F zooms in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.5)) { showLetter0 = true }
            
            // t=0.6s — R
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.5)) { showLetter1 = true }
            
            // t=0.9s — A
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.5)) { showLetter2 = true }
            
            // t=1.2s — I
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.5)) { showLetter3 = true }
            
            // t=1.5s — L
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.5)) { showLetter4 = true }
            
            // t=2.3s — Title starts slow breathing
            try? await Task.sleep(nanoseconds: 800_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                titlePulse = true
            }
            
            // t=3.2s — Title shrinks to top
            try? await Task.sleep(nanoseconds: 900_000_000)
            guard !Task.isCancelled else { return }
            titleShrunk = true
            
            // t=4.6s — Earth fades in + Nova starts orbiting
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeIn(duration: 1.5)) {
                earthVisible = true
            }
            
            // Tell NovaController to start orbiting around Earth as fallback
            // Primary trigger is now earthVisible onChange for better timing
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            if earthVisible && !didTap && !nova.isOrbiting {
                nova.orbitAround(cx: earthCX, cy: earthCY, radius: 340)
            }
            
            // t=6.5s — "Tap anywhere" appears
            try? await Task.sleep(nanoseconds: 1_900_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeIn(duration: 0.5)) {
                showTapHint = true
            }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                tapHintPulse = true
            }
        }
    }
}

#Preview {
    IntroView(onFinished: {})
        .environmentObject(NovaController())
}

