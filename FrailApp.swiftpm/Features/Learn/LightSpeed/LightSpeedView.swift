//
//  LightSpeedView.swift
//  Frail
//
//  Lesson 3: The Speed of Light
//

import SwiftUI

struct LightSpeedView: View {
    let onComplete: () -> Void
    
    @State private var speedOfLightMultiplier: Double = 1.0
    @State private var showSummary = false
    @State private var showNovaBubble = false
    @State private var novaMessage = ""
    @State private var redshiftTint: Double = 0.0
    @State private var blueshiftTint: Double = 0.0
    
    var body: some View {
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
            
            // Nova speech bubble
            if showNovaBubble {
                VStack {
                    Spacer()
                    HStack {
                        NovaView(state: .speaking)
                        SpeechBubbleView(text: novaMessage) {
                            showNovaBubble = false
                        }
                        Spacer()
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .onAppear {
            showNovaMessage(NovaCopy.LightSpeed.entry)
        }
    }
    
    private func updateSpeedOfLight(_ multiplier: Double) {
        speedOfLightMultiplier = multiplier
        updateTint()
        
        let intensity = Float(multiplier / 5.0).clamped(to: 0...1)
        HapticEngine.shared.playSliderMove(intensity: intensity)
        
        if (multiplier < 0.3 || multiplier > 2.0) && !showSummary {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showSummary = true
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
