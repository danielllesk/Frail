import SwiftUI

struct HomeView: View {
    let onLearnTapped: () -> Void
    let onBuildTapped: () -> Void
    let onChallengeTapped: () -> Void
    let onWitnessTapped: () -> Void
    
    @EnvironmentObject var nova: NovaController
    
    // MARK: - Animation state
    @State private var hasAnimated = false
    
    // Earth: starts large at center, shrinks & moves up
    @State private var earthSettled = false
    
    // Title: starts large, shrinks to top
    @State private var titleSettled = false
    
    // Typewriter subtitle
    @State private var subtitleText = ""
    private let fullSubtitle = "Touch the constants."
    
    // Nova speech bubble
    @State private var showNovaIntro = false
    
    // Cards
    @State private var cardsVisible = false
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            ZStack {
                // ── Earth ──
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
                        .frame(width: 600, height: 600)
                        .blur(radius: 12)
                    
                    EarthSceneView()
                        .frame(width: 600, height: 600)
                        .clipShape(Circle())
                }
                .scaleEffect(earthSettled ? 0.75 : 1.0)
                .position(
                    x: w / 2,
                    y: earthSettled ? h * 0.36 : h * 0.48
                )
                
                // ── FRAIL title ──
                VStack(spacing: 4) {
                    Text("FRAIL")
                        .font(.system(
                            size: titleSettled ? 22 : 60,
                            weight: .bold,
                            design: .rounded
                        ))
                        .tracking(titleSettled ? 3 : 6)
                        .foregroundColor(.frailPrimaryText)
                    
                    // Typewriter subtitle
                    if !subtitleText.isEmpty {
                        Text(subtitleText)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.frailMutedText)
                            .transition(.opacity)
                    }
                }
                .position(
                    x: w / 2,
                    y: titleSettled ? h * 0.06 : h * 0.12
                )
                
                // ── Bottom content: Nova + Cards ──
                VStack(spacing: 16) {
                    Spacer()
                    
                    // Nova intro speech bubble
                    if showNovaIntro {
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
                            
                            let hasLaunched = UserDefaults.standard.bool(forKey: "hasLaunched")
                            Text(hasLaunched ? NovaCopy.Intro.welcome : NovaCopy.Home.novaIntro)
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.frailPrimaryText)
                                .lineSpacing(4)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
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
                    
                    // Section cards
                    VStack(spacing: 14) {
                        FrailCard(
                            title: "Learn",
                            subtitle: "Three lessons on time, gravity, and the speed of light.",
                            index: 1,
                            action: onLearnTapped
                        )
                        .opacity(cardsVisible ? 1 : 0)
                        .offset(y: cardsVisible ? 0 : 40)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.0), value: cardsVisible)
                        
                        FrailCard(
                            title: "Build",
                            subtitle: "Assemble a solar system. See if it holds.",
                            index: 2,
                            action: onBuildTapped
                        )
                        .opacity(cardsVisible ? 1 : 0)
                        .offset(y: cardsVisible ? 0 : 40)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: cardsVisible)
                        
                        FrailCard(
                            title: "Challenge",
                            subtitle: "Diagnose dead universes. Judge what could live.",
                            index: 3,
                            action: onChallengeTapped
                        )
                        .opacity(cardsVisible ? 1 : 0)
                        .offset(y: cardsVisible ? 0 : 40)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: cardsVisible)
                        
                        FrailCard(
                            title: "Witness",
                            subtitle: "Two galaxies collide. No interaction required.",
                            index: 4,
                            action: onWitnessTapped
                        )
                        .opacity(cardsVisible ? 1 : 0)
                        .offset(y: cardsVisible ? 0 : 40)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: cardsVisible)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                        .frame(height: 40)
                }
            }
            .onAppear {
                nova.hide()
                guard !hasAnimated else { return }
                hasAnimated = true
                startCinematicEntry()
            }
        }
    }
    
    // MARK: - Cinematic entry sequence
    
    private func startCinematicEntry() {
        // t=0.3s — Earth shrinks & moves up, title shrinks to top
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 1.2)) {
                earthSettled = true
                titleSettled = true
            }
        }
        
        // t=1.2s — Typewriter subtitle
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            typewriterAnimate()
        }
        
        // t=2.0s — Nova speech bubble
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showNovaIntro = true
            }
            UserDefaults.standard.set(true, forKey: "hasLaunched")
            HapticEngine.shared.playNovaSpeak()
        }
        
        // t=2.5s — Cards cascade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            cardsVisible = true
        }
        
        // Nova speech bubble stays visible until user navigates away
    }
    
    private func typewriterAnimate() {
        subtitleText = ""
        let chars = Array(fullSubtitle)
        for (i, char) in chars.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.045) {
                subtitleText += String(char)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.frailBackground.ignoresSafeArea()
        StarFieldView().ignoresSafeArea()
        HomeView(
            onLearnTapped: {},
            onBuildTapped: {},
            onChallengeTapped: {},
            onWitnessTapped: {}
        )
    }
    .environmentObject(NovaController())
}
