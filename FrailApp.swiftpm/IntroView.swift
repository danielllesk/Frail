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
    @State private var showOrbitNova = false
    @State private var showTapHint = false
    @State private var titlePulse = false
    @State private var tapHintPulse = false
    @State private var didTap = false
    @State private var novaFlyX: CGFloat = 0
    @State private var novaFlyY: CGFloat = 0
    @State private var showWelcome = false
    @State private var showContinue = false
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let earthCX = w / 2
            let earthCY = h * 0.42
            let orbitR: CGFloat = min(w, h) * 0.22
            
            ZStack {
                // ── Black background ──
                Color.frailBackground
                    .ignoresSafeArea()
                
                // ── TITLE ──
                titleLetters
                    .scaleEffect(titleShrunk ? 0.4 : 1.0)
                    .opacity(titlePulse ? 0.5 : 1.0)
                    .position(
                        x: w / 2,
                        y: titleShrunk ? h * 0.07 : h / 2
                    )
                    .animation(.easeInOut(duration: 1.2), value: titleShrunk)
                
                // ── EARTH ──
                if earthVisible {
                    ZStack {
                        // Glow
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
                            .frame(width: 360, height: 360)
                            .blur(radius: 10)
                        
                        EarthSceneView()
                            .frame(width: 280, height: 280)
                            .clipShape(Circle())
                    }
                    .position(x: earthCX, y: earthCY)
                    .transition(.opacity)
                }
                
                // ── NOVA orbiting ──
                if showOrbitNova && !didTap {
                    let nx = earthCX + orbitR * cos(novaOrbitAngle * .pi / 180)
                    let ny = earthCY + orbitR * sin(novaOrbitAngle * .pi / 180)
                    
                    NovaView(state: .idle)
                        .frame(width: 36, height: 36)
                        .position(x: nx, y: ny)
                }
                
                // ── Tap hint ──
                if showTapHint && !didTap {
                    Text("Tap anywhere")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.frailMutedText)
                        .tracking(2)
                        .opacity(tapHintPulse ? 0.3 : 1.0)
                        .position(x: w / 2, y: h * 0.73)
                }
                
                // ── Nova flying after tap ──
                if didTap && !showWelcome {
                    NovaView(state: .speaking)
                        .frame(width: 48, height: 48)
                        .position(x: novaFlyX, y: novaFlyY)
                }
                
                // ── Welcome + Continue ──
                if showWelcome {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        HStack(alignment: .center, spacing: 14) {
                            NovaView(state: .speaking)
                                .frame(width: 48, height: 48)
                            
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
                        .transition(.opacity.combined(with: .offset(y: 30)))
                        
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
                
                let nx = earthCX + orbitR * cos(novaOrbitAngle * .pi / 180)
                let ny = earthCY + orbitR * sin(novaOrbitAngle * .pi / 180)
                novaFlyX = nx
                novaFlyY = ny
                
                withAnimation(.easeOut(duration: 0.3)) {
                    showTapHint = false
                }
                didTap = true
                
                let targetX = w * 0.18
                let targetY = h * 0.78
                withAnimation(.spring(response: 0.8, dampingFraction: 0.72)) {
                    novaFlyX = targetX
                    novaFlyY = targetY
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showWelcome = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showContinue = true
                    }
                }
            }
            .onAppear {
                beginSequence(earthCX: earthCX, earthCY: earthCY)
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
                .font(.system(size: 72, weight: .heavy, design: .rounded))
                .foregroundColor(.frailAccent.opacity(0.25))
                .blur(radius: 20)
            
            // Tight bloom
            Text(char)
                .font(.system(size: 72, weight: .heavy, design: .rounded))
                .foregroundColor(.white.opacity(0.4))
                .blur(radius: 6)
            
            // Sharp letter
            Text(char)
                .font(.system(size: 72, weight: .heavy, design: .rounded))
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
        
        // t=2.3s — Title starts pulsing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                titlePulse = true
            }
        }
        
        // t=3.2s — Title shrinks to top, stop pulse
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            withAnimation(.easeInOut(duration: 1.2)) {
                titlePulse = false
            }
            titleShrunk = true
        }
        
        // t=4.6s — Earth fades in + Nova starts orbiting
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.6) {
            withAnimation(.easeIn(duration: 1.5)) {
                earthVisible = true
            }
            showOrbitNova = true
            startOrbit()
        }
        
        // t=6.5s — "Tap anywhere" appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.5) {
            withAnimation(.easeIn(duration: 0.5)) {
                showTapHint = true
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                tapHintPulse = true
            }
        }
    }
    
    private func startOrbit() {
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            Task { @MainActor in
                novaOrbitAngle += 0.35
                if novaOrbitAngle >= 360 {
                    novaOrbitAngle -= 360
                }
            }
        }
    }
}

#Preview {
    IntroView(onFinished: {})
}
