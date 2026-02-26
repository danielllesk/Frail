//
//  AppRootView.swift
//  Frail
//
//  High-level app shell: intro greeting then main root navigation.
//

import SwiftUI

struct AppRootView: View {
    @State private var hasSeenIntro = false
    
    var body: some View {
        ZStack {
            if hasSeenIntro {
                RootView()
                    .transition(.opacity.combined(with: .move(edge: .top)))
            } else {
                IntroView {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
                        hasSeenIntro = true
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
    }
}

#Preview {
    AppRootView()
}

