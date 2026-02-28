//
//  NovaView.swift
//  Frail
//
//  Nova orb component, all states
//

import SwiftUI

enum NovaState {
    case idle
    case speaking
    case neutral
    case affirming
    case warning
    case critical
    case happy
}

struct NovaView: View {
    let state: NovaState
    let size: CGFloat
    
    @State private var breatheScale: CGFloat = 1.0
    @State private var flickerOpacity: Double = 1.0
    @State private var idleVariant: Int = Int.random(in: 0...1)
    
    // Debug pulse for simulator
    @State private var hapticPulseScale: CGFloat = 1.0
    @State private var hapticPulseOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            novaColor.opacity(0.45),
                            novaColor.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: size * 0.5,
                        endRadius: size * 0.8
                    )
                )
                .frame(width: size * 1.9, height: size * 1.9)
                .blur(radius: 18)
                .opacity(flickerOpacity)
            
            // Main orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            novaColor,
                            novaEdgeColor
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size, height: size)
                .scaleEffect(breatheScale)
            
            // Speaking ring animation
            if state == .speaking {
                Circle()
                    .stroke(novaColor.opacity(0.4), lineWidth: 2)
                    .frame(width: size * 1.2, height: size * 1.2)
                    .scaleEffect(breatheScale * 1.1)
                    .opacity(1.0 - breatheScale)
            }
            
            // Haptic Debug Pulse (Simulator only)
            Circle()
                .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                .frame(width: size * 0.9, height: size * 0.9)
                .scaleEffect(hapticPulseScale)
                .opacity(hapticPulseOpacity)
        }
        .onReceive(NotificationCenter.default.publisher(for: HapticEngine.hapticDebugFired)) { note in
            triggerDebugPulse(intensity: note.object as? Float ?? 0.5)
        }
        .onAppear {
            startBreathing()
            startFlicker()
        }
        .onChange(of: state) { _ in
            startBreathing()
            if state == .idle || state == .neutral {
                startFlicker()
            }
        }
    }
    
    private var novaColor: Color {
        switch state {
        case .idle, .speaking, .neutral, .happy:
            return .novaCenter
        case .affirming:
            return .frailGold
        case .warning:
            return .frailAmber
        case .critical:
            return .frailCrimson
        }
    }
    
    private var novaEdgeColor: Color {
        switch state {
        case .idle, .speaking, .neutral, .happy:
            return .novaEdge
        case .affirming:
            return .frailGold.opacity(0.5)
        case .warning:
            return .frailAmber.opacity(0.5)
        case .critical:
            return .frailCrimson.opacity(0.5)
        }
    }
    
    private func startBreathing() {
        let baseDuration: Double = state == .speaking ? 1.6 : (idleVariant == 0 ? 2.8 : 3.6)
        let targetScale: CGFloat = state == .speaking ? 1.07 : 1.04
        let startScale: CGFloat = 0.96
        
        breatheScale = startScale
        
        withAnimation(.easeInOut(duration: baseDuration).repeatForever(autoreverses: true)) {
            breatheScale = targetScale
        }
    }
    
    @State private var flickerTask: Task<Void, Never>?
    
    private func startFlicker() {
        flickerTask?.cancel()
        
        guard state == .idle || state == .neutral else {
            flickerOpacity = 1.0
            return
        }
        
        let baseDelay: Double = idleVariant == 0 ? 1.8 : 2.6
        let flickerAmount: Double = 0.15
        
        flickerTask = Task {
            while !Task.isCancelled {
                let jitter = Double.random(in: -0.4...0.4)
                try? await Task.sleep(nanoseconds: UInt64((baseDelay + jitter) * 1_000_000_000))
                if Task.isCancelled { break }
                
                withAnimation(.easeInOut(duration: 0.25)) {
                    flickerOpacity = 1.0 - flickerAmount
                }
                
                try? await Task.sleep(nanoseconds: UInt64(0.25 * 1_000_000_000))
                if Task.isCancelled { break }
                
                withAnimation(.easeInOut(duration: 0.35)) {
                    flickerOpacity = 1.0
                }
            }
        }
    }
    
    private func triggerDebugPulse(intensity: Float) {
        hapticPulseScale = 1.0
        hapticPulseOpacity = Double(intensity)
        
        withAnimation(.easeOut(duration: 0.4)) {
            hapticPulseScale = 1.6 + CGFloat(intensity) * 0.4
            hapticPulseOpacity = 0.0
        }
    }
}
