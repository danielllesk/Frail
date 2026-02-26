import SwiftUI

struct HomeView: View {
    let onLearnTapped: () -> Void
    let onBuildTapped: () -> Void
    let onChallengeTapped: () -> Void
    let onWitnessTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Title / Nova placeholder area
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Frail")
                        .font(.system(size: 32, weight: .medium, design: .rounded))
                        .foregroundColor(.frailPrimaryText)
                    Text("The universe is delicate.\nTouch the constants.")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.frailMutedText)
                }
                
                Spacer()
                
                // Nova orb placeholder (top-right)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.novaCenter, Color.novaEdge],
                            center: .center,
                            startRadius: 0,
                            endRadius: 24
                        )
                    )
                    .frame(width: 48, height: 48)
                    .shadow(color: Color.novaGlow.opacity(0.2), radius: 12)
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            VStack(spacing: 16) {
                HomeCard(
                    title: "Learn",
                    subtitle: "Three lessons on time, gravity, and constants.",
                    action: onLearnTapped
                )
                
                HomeCard(
                    title: "Build",
                    subtitle: "Assemble a solar system. See if it holds.",
                    action: onBuildTapped
                )
                
                HomeCard(
                    title: "Challenge",
                    subtitle: "Diagnose dead universes. Judge what could live.",
                    action: onChallengeTapped
                )
                
                HomeCard(
                    title: "Witness",
                    subtitle: "Two galaxies collide. No interaction required.",
                    action: onWitnessTapped
                )
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
}

private struct HomeCard: View {
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundColor(.frailPrimaryText)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.frailMutedText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
        }
        .buttonStyle(.plain)
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

