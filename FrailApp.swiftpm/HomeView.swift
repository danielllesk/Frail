import SwiftUI

struct HomeView: View {
    let onLearnTapped: () -> Void
    let onBuildTapped: () -> Void
    let onChallengeTapped: () -> Void
    let onWitnessTapped: () -> Void
    
    @State private var showNovaIntro = false
    @State private var cardsVisible = false
    @State private var hasAnimated = false
    
    var body: some View {
        VStack(spacing: 0) {
            // --- Header: Title + Nova orb ---
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("FRAIL")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .tracking(3)
                        .foregroundColor(.frailPrimaryText)
                    
                    Text("Touch the constants.")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.frailMutedText)
                }
                
                Spacer()
                
                // Full Nova orb with idle breathing
                NovaView(state: .idle)
                    .frame(width: 48, height: 48)
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
            
            // --- Nova intro speech bubble ---
            if showNovaIntro {
                HStack(alignment: .top, spacing: 0) {
                    Spacer()
                        .frame(width: 24)
                    
                    Text(NovaCopy.Home.novaIntro)
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
                        .frame(width: 24)
                }
                .padding(.top, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            Spacer()
            
            // --- Section cards ---
            VStack(spacing: 14) {
                FrailCard(
                    title: "Learn",
                    subtitle: "Three lessons on time, gravity, and the speed of light.",
                    index: 1,
                    action: onLearnTapped
                )
                .opacity(cardsVisible ? 1 : 0)
                .offset(y: cardsVisible ? 0 : 20)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.0), value: cardsVisible)
                
                FrailCard(
                    title: "Build",
                    subtitle: "Assemble a solar system. See if it holds.",
                    index: 2,
                    action: onBuildTapped
                )
                .opacity(cardsVisible ? 1 : 0)
                .offset(y: cardsVisible ? 0 : 20)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: cardsVisible)
                
                FrailCard(
                    title: "Challenge",
                    subtitle: "Diagnose dead universes. Judge what could live.",
                    index: 3,
                    action: onChallengeTapped
                )
                .opacity(cardsVisible ? 1 : 0)
                .offset(y: cardsVisible ? 0 : 20)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: cardsVisible)
                
                FrailCard(
                    title: "Witness",
                    subtitle: "Two galaxies collide. No interaction required.",
                    index: 4,
                    action: onWitnessTapped
                )
                .opacity(cardsVisible ? 1 : 0)
                .offset(y: cardsVisible ? 0 : 20)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3), value: cardsVisible)
            }
            .padding(.horizontal, 24)
            
            Spacer()
                .frame(height: 40)
        }
        .onAppear {
            guard !hasAnimated else { return }
            hasAnimated = true
            startEntryAnimation()
        }
    }
    
    private func startEntryAnimation() {
        // Cards cascade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            cardsVisible = true
        }
        
        // Nova intro speech appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showNovaIntro = true
            }
            HapticEngine.shared.playNovaSpeak()
        }
        
        // Auto-dismiss Nova intro after 9 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 9.0) {
            withAnimation(.easeOut(duration: 0.4)) {
                showNovaIntro = false
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
}
