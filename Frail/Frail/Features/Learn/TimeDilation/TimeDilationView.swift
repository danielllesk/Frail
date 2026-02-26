//
//  TimeDilationView.swift
//  Frail
//
//  Lesson 1: Time Dilation (Twin Paradox)
//

import SwiftUI

struct TimeDilationView: View {
    let onComplete: () -> Void
    
    @State private var velocity: Double = 0.0
    @State private var aliceTimeMultiplier: Double = 1.0
    @State private var showSummary = false
    @State private var showNovaBubble = false
    @State private var novaMessage = ""
    
    var body: some View {
        ZStack {
            VStack(spacing: 32) {
                // Alice and Bob split screen
                HStack(spacing: 0) {
                    // Alice (left)
                    VStack {
                        Text("Alice")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.frailPrimaryText)
                        
                        ClockView(
                            timeMultiplier: aliceTimeMultiplier,
                            label: "Rocket"
                        )
                    }
                    .frame(maxWidth: .infinity)
                    
                    Divider()
                        .background(Color.frailMutedText.opacity(0.3))
                    
                    // Bob (right)
                    VStack {
                        Text("Bob")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.frailPrimaryText)
                        
                        ClockView(
                            timeMultiplier: 1.0,
                            label: "Earth"
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)
                
                // Velocity slider
                VStack(alignment: .leading, spacing: 12) {
                    Text("Velocity: \(Int(velocity * 100))% c")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.frailPrimaryText)
                    
                    Slider(
                        value: $velocity,
                        in: 0...0.99
                    ) {
                        Text("Velocity")
                    } minimumValueLabel: {
                        Text("0%")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.frailMutedText)
                    } maximumValueLabel: {
                        Text("99%")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.frailMutedText)
                    }
                    .tint(.frailAccent)
                    .onChange(of: velocity) { oldValue, newValue in
                        updateVelocity(newValue)
                        showNovaMessage(NovaCopy.TimeDilation.slider(at: newValue))
                    }
                }
                .padding(.horizontal, 24)
                
                // Summary card
                if showSummary {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NovaCopy.TimeDilation.summary)
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
            showNovaMessage(NovaCopy.TimeDilation.entry)
        }
    }
    
    private func updateVelocity(_ newVelocity: Double) {
        velocity = newVelocity
        aliceTimeMultiplier = timeDilationFactor(velocity: newVelocity)
        
        // Haptic feedback
        HapticEngine.shared.playTimeDilationPulse(velocity: newVelocity)
        
        // Check for summary
        if newVelocity > 0.9 && !showSummary {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showSummary = true
            }
        }
    }
    
    private func timeDilationFactor(velocity: Double) -> Double {
        guard velocity > 0 && velocity < 1.0 else { return 1.0 }
        let vOverC = velocity
        let denominator = sqrt(1.0 - (vOverC * vOverC))
        return 1.0 / denominator
    }
    
    private func showNovaMessage(_ message: String) {
        novaMessage = message
        showNovaBubble = true
        HapticEngine.shared.playNovaSpeak()
    }
}
