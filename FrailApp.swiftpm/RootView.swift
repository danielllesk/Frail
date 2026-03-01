//
//  RootView.swift
//  Frail
//
//  Root navigation coordinator
//

import SwiftUI

enum AppScreen {
    case home
    case learn
    case build
    case challenge
    case witness
}

struct RootView: View {
    @State private var currentScreen: AppScreen = .home
    
    var body: some View {
        ZStack {
            // Background is handled by AppRootView globally
            
            switch currentScreen {
            case .home:
                HomeView(
                    onLearnTapped: { currentScreen = .learn },
                    onBuildTapped: { currentScreen = .build },
                    onChallengeTapped: { currentScreen = .challenge },
                    onWitnessTapped: { currentScreen = .witness }
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            case .learn:
                LearnContainerView(
                    onComplete: { currentScreen = .home }
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            case .build:
                BuildView(
                    onBack: { currentScreen = .home }
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            case .challenge:
                ChallengeView(
                    onBack: { currentScreen = .home }
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            case .witness:
                WitnessView(
                    onBack: { currentScreen = .home }
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: currentScreen)
    }
}

#Preview {
    RootView()
}
