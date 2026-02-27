//
//  GravityView.swift
//  Frail
//
//  Lesson 2: Gravity & Orbits
//

import SwiftUI

struct GravityView: View {
    let onComplete: () -> Void
    @EnvironmentObject var nova: NovaController
    
    @State private var gravityMultiplier: Double = 1.0
    @State private var showSummary = false
    @State private var showNovaBubble = false
    @State private var novaMessage = ""
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 32) {
                    // Earth and Moon orbit visualization
                    OrbitView(
                        gravityMultiplier: gravityMultiplier
                    )
                    .frame(height: 300)
                    
                    // Gravity slider
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Gravity: \(String(format: "%.1f", gravityMultiplier))x Earth")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.frailPrimaryText)
                        
                        Slider(
                            value: $gravityMultiplier,
                            in: 0.1...5.0
                        ) {
                            Text("Gravity")
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
                        .onChange(of: gravityMultiplier) { newValue in
                            updateGravity(newValue)
                            showNovaMessage(NovaCopy.Gravity.slider(at: newValue))
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Summary card
                    if showSummary {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NovaCopy.Gravity.summary)
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
                showNovaMessage(NovaCopy.Gravity.entry)
            }
        }
    }
    
    private func updateGravity(_ multiplier: Double) {
        gravityMultiplier = multiplier
        HapticEngine.shared.playGravityIntensity(multiplier: multiplier)
        
        if multiplier > 4.0 && !showSummary {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showSummary = true
            }
        }
    }
    
    private func showNovaMessage(_ message: String) {
        novaMessage = message
        showNovaBubble = true
        HapticEngine.shared.playNovaSpeak()
    }
}

