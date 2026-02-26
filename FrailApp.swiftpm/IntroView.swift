//
//  IntroView.swift
//  Frail
//
//  Cinematic intro — Netflix-style title zoom, orbiting Nova, tap-to-start.
//

import SwiftUI

struct IntroView: View {
    let onFinished: () -> Void
    
    // MARK: - Letter animation
    @State private var showLetter0 = false
    @State private var showLetter1 = false
    @State private var showLetter2 = false
    @State private var showLetter3 = false
    @State private var showLetter4 = false
    
    // MARK: - Phase animation
    @State private var titleShrunk = false
    @State private var earthVisible = false
    @State private var novaOrbitAngle: Double = 0
    @State private var novaVisible = false
    @State private var showTapHint = false
    @State private var titlePulse = false
    @State private var tapHintPulse = false
    @State private var didTap = false
    @State private var showWelcome = false
    @State private var showContinue = false
    @State private var orbitTimer: Timer?
    
    // Nova position — single source of truth
    @State private var novaX: CGFloat = 0
    @State private var novaY: CGFloat = 0
    @State private var novaSize: CGFloat = 36
    
    // Earth layout — kept in sync with geometry
    @State private var earthCenterX: CGFloat = 0
    @State private var earthCenterY: CGFloat = 0
    @State private var orbitRadius: CGFloat = 340
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let earthCX = w / 2
            let earthCY = h * 0.48
            let orbitR: CGFloat = 340
            
            ZStack {
                // ── Black background ──
                Color.frailBackground
                    .ignoresSafeArea()
                
                // ── Stars ──
                StarFieldView()
                    .ignoresSafeArea()
                
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
                
                // ═══════════════════════════════════════
                // SINGLE NOVA — one continuous character
                // Position is animated, never removed
                // ═══════════════════════════════════════
                if novaVisible {
                    NovaView(state: didTap ? .speaking : .idle)
                        .frame(width: novaSize, height: novaSize)
                        .position(x: novaX, y: novaY)
                        .animation(.spring(response: 0.8, dampingFraction: 0.72), value: novaX)
                        .animation(.spring(response: 0.8, dampingFraction: 0.72), value: novaY)
                        .animation(.easeInOut(duration: 0.3), value: novaSize)
                }
                
                // ── Tap hint ──
                if showTapHint && !didTap {
                    Text("Tap anywhere")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.frailMutedText)
                        .tracking(2)
                        .opacity(tapHintPulse ? 0.3 : 1.0)
                        .position(x: w / 2, y: h * 0.93)
                }
                
                // ── Welcome bubble + Continue (no Nova here, it's above) ──
                if showWelcome {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        // Speech bubble only — Nova is already positioned nearby
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
                            .padding(.leading, 70) // offset to the right of Nova
                            .transition(.opacity.combined(with: .offset(y: 20)))
                        
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
                    .padding(.bottom, 50)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                guard showTapHint && !didTap else { return }
                
                // Stop orbit
                orbitTimer?.invalidate()
                orbitTimer = nil
                
                // Hide tap hint
                withAnimation(.easeOut(duration: 0.3)) {
                    showTapHint = false
                }
                
                didTap = true
                
                // Grow Nova slightly
                novaSize = 48
                
                // Fly Nova smoothly to bottom-left
                novaX = 48
                novaY = h - 120
                
                // Show welcome bubble after Nova arrives
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
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
                earthCenterX = earthCX
                earthCenterY = earthCY
                orbitRadius = orbitR
                beginSequence()
            }
            .onDisappear {
                orbitTimer?.invalidate()
                orbitTimer = nil
            }
            .onChange(of: geo.size) { _ in
                earthCenterX = geo.size.width / 2
                earthCenterY = geo.size.height * 0.48
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
    
    private func beginSequence() {
        // t=0.3s — F zooms in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.5)) {
                showLetter0 = true
            }
        }
        // t=0.6s — R
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.5)) {
                showLetter1 = true
            }
        }
        // t=0.9s — A
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.easeOut(duration: 0.5)) {
                showLetter2 = true
            }
        }
        // t=1.2s — I
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.5)) {
                showLetter3 = true
            }
        }
        // t=1.5s — L
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                showLetter4 = true
            }
        }
        
        // t=2.3s — Title starts slow breathing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                titlePulse = true
            }
        }
        
        // t=3.2s — Title shrinks to top (pulse continues)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            titleShrunk = true
        }
        
        // t=4.6s — Earth fades in + Nova appears and starts orbiting
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.6) {
            withAnimation(.easeIn(duration: 1.5)) {
                earthVisible = true
            }
            
            // Set Nova's initial orbit position
            let startAngle = 0.0
            novaX = earthCenterX + orbitRadius * cos(startAngle * .pi / 180)
            novaY = earthCenterY + orbitRadius * sin(startAngle * .pi / 180)
            novaVisible = true
            
            startOrbit()
        }
        
        // t=6.5s — "Tap anywhere" appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.5) {
            withAnimation(.easeIn(duration: 0.5)) {
                showTapHint = true
            }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                tapHintPulse = true
            }
        }
    }
    
    private func startOrbit() {
        orbitTimer?.invalidate()
        orbitTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            Task { @MainActor in
                novaOrbitAngle += 0.35
                if novaOrbitAngle >= 360 {
                    novaOrbitAngle -= 360
                }
                // Read from @State — always in sync with Earth's actual center
                novaX = earthCenterX + orbitRadius * cos(novaOrbitAngle * .pi / 180)
                novaY = earthCenterY + orbitRadius * sin(novaOrbitAngle * .pi / 180)
            }
        }
    }
}

#Preview {
    IntroView(onFinished: {})
}
