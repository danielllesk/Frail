//
//  AppRootView.swift
//  Frail
//
//  High-level app shell: intro greeting then main root navigation.
//  Renders the SINGLE persistent NovaView at the top ZStack level.
//

import SwiftUI

struct AppRootView: View {
    @State private var hasSeenIntro = false
    @StateObject private var nova = NovaController()
    private let starController = StarFieldController.shared
    
    var body: some View {
        GeometryReader { _ in
            ZStack {
                // ═══════════════════════════════════════
                // GLOBAL PERSISTENT BACKGROUND
                // ═══════════════════════════════════════
                Color.frailBackground
                    .ignoresSafeArea()
                
                StarFieldView(controller: starController)
                    .ignoresSafeArea()
                
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
                
                // ═══════════════════════════════════════
                // SINGLE PERSISTENT NOVA — always on top
                // ═══════════════════════════════════════
                if nova.visible {
                    NovaView(state: nova.state, size: nova.size)
                        .frame(width: nova.size, height: nova.size)
                        .position(x: nova.x, y: nova.y)
                }
            }
            .coordinateSpace(name: "appRoot")
        }
        .ignoresSafeArea()
        .environmentObject(nova)
        .environmentObject(starController)
    }
}

#Preview {
    AppRootView()
}
