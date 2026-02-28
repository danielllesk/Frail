//
//  LightSpeedView.swift
//  Frail
//
//  Lesson 3: The Speed of Light
//

import SwiftUI

struct LightSpeedView: View {
    let onComplete: () -> Void
    @EnvironmentObject var nova: NovaController
    
    @State private var speedOfLightMultiplier: Double = 1.0
    @State private var showSummary = false
    @State private var showNovaBubble = false
    @State private var novaMessage = ""
    @State private var redshiftTint: Double = 0.0
    @State private var blueshiftTint: Double = 0.0
    @State private var sequenceTask: Task<Void, Never>? = nil
    
    var body: some View {
        GeometryReader { _ in
            ZStack {
                // Background tint for redshift/blueshift
                Color(red: redshiftTint, green: 0, blue: blueshiftTint)
                    .opacity(0.1)
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Atom visualization
                    AtomView(
                        speedOfLightMultiplier: speedOfLightMultiplier
                    )
                    .frame(height: 300)
                    
                    // Speed of light slider
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Speed of Light: \(String(format: "%.1f", speedOfLightMultiplier))x c")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.frailPrimaryText)
                        
                        Slider(
                            value: $speedOfLightMultiplier,
                            in: 0.1...5.0
                        ) {
                            Text("Speed of Light")
                        } minimumValueLabel: {
                            Text("0.1x")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.frailMutedText)
                        } maximumValueLabel: {
                            Text("5x")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.frailMutedText)
                        }
                        .tint(.frailAccent)
                        .onChange(of: speedOfLightMultiplier) { newValue in
                            updateSpeedOfLight(newValue)
                            showNovaMessage(NovaCopy.LightSpeed.slider(at: newValue))
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Summary card
                    if showSummary {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NovaCopy.LightSpeed.summary)
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundColor(.frailPrimaryText)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        )
                        .padding(.horizontal, 24)
                        
                        Button(action: onComplete) {
                            Text("Continue")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.frailPrimaryText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.frailAccent)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    Spacer()
                }
                .padding(.top, 40)
                
                // Speech bubble (Nova rendered by AppRootView)
                if showNovaBubble {
                    VStack {
                        Spacer()
                        HStack(spacing: 8) {
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
                            SpeechBubbleView(text: novaMessage) {
                                showNovaBubble = false
                                nova.state = .idle
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 100)
                    }
                    .onPreferenceChange(NovaSlotPreferenceKey.self) { pos in
                        if pos != .zero {
                            nova.flyTo(x: pos.x, y: pos.y, size: 48, state: .speaking)
                        }
                    }
                }
            }
            .onAppear {
                showNovaMessage(NovaCopy.LightSpeed.entry)
            }
            .onDisappear {
                sequenceTask?.cancel()
                sequenceTask = nil
            }
        }
    }
    
    private func updateSpeedOfLight(_ multiplier: Double) {
        speedOfLightMultiplier = multiplier
        updateTint()
        
        let intensity = Float(multiplier / 5.0).clamped(to: 0...1)
        HapticEngine.shared.playSliderMove(intensity: intensity)
        
        if (multiplier < 0.3 || multiplier > 2.0) && !showSummary {
            sequenceTask?.cancel()
            sequenceTask = Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                guard !Task.isCancelled else { return }
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showSummary = true
                }
            }
        }
    }
    
    private func updateTint() {
        // Redshift (slower light) = red tint
        // Blueshift (faster light) = blue tint
        if speedOfLightMultiplier < 1.0 {
            redshiftTint = 1.0 - speedOfLightMultiplier
            blueshiftTint = 0.0
        } else {
            redshiftTint = 0.0
            blueshiftTint = (speedOfLightMultiplier - 1.0) / 4.0
        }
    }
    
    private func showNovaMessage(_ message: String) {
        novaMessage = message
        showNovaBubble = true
        HapticEngine.shared.playNovaSpeak()
    }
}
