//
//  IntroView.swift
//  Frail
//
//  Greeting screen with slowly rotating Earth and Nova.
//

import SwiftUI

struct IntroView: View {
    let onFinished: () -> Void
    
    @State private var showTapToBegin = false
    @State private var displayedTitleCount: Int = 0
    
    private let fullTitle = "FRAIL"
    
    var body: some View {
        ZStack {
            // Cosmic background
            Color.frailBackground
                .ignoresSafeArea()
            
            StarFieldView()
                .ignoresSafeArea()
            
            // Rotating Earth
            VStack {
                Spacer()
                
                EarthSceneView()
                    .frame(width: 260, height: 260)
                    .shadow(color: .black.opacity(0.8), radius: 50, x: 0, y: 36)
                
                Spacer()
            }
            
            VStack(spacing: 24) {
                Spacer().frame(height: 60)
                
                VStack(spacing: 8) {
                    ZStack {
                        // Glow behind title
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.white.opacity(0.25),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 120
                                )
                            )
                            .frame(width: 220, height: 70)
                            .opacity(showTapToBegin ? 1 : 0.6)
                            .blur(radius: 6)
                        
                        Text(currentTitle)
                            .font(.system(size: 40, weight: .semibold, design: .rounded))
                            .tracking(6)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color.white,
                                        Color.white.opacity(0.9)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .black.opacity(0.6), radius: 10, x: 0, y: 4)
                            .accessibilityLabel("Frail")
                    }
                    
                    Text("Where even light feels fragile")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.frailMutedText)
                        .opacity(showTapToBegin ? 1 : 0)
                        .animation(.easeIn(duration: 0.8), value: showTapToBegin)
                }
                
                Spacer()
                
                if showTapToBegin {
                    VStack(spacing: 16) {
                        HStack(alignment: .center, spacing: 12) {
                            NovaView(state: .idle)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Welcome. The universe you know is balanced on fragile constants.")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(.frailPrimaryText)
                                
                                Text("Tap to begin.")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.frailAccent)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.frailMentorBg)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.frailMentorBorder, lineWidth: 1)
                                    )
                            )
                        }
                        
                        Text("Tap anywhere to continue")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.frailMutedText)
                            .opacity(0.8)
                    }
                    .padding(.bottom, 60)
                    .padding(.horizontal, 24)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if showTapToBegin {
                onFinished()
            }
        }
        .onAppear {
            startTitleTyping()
        }
    }
    
    private var currentTitle: String {
        let endIndex = fullTitle.index(fullTitle.startIndex, offsetBy: min(displayedTitleCount, fullTitle.count))
        return String(fullTitle[..<endIndex])
    }
    
    private func startTitleTyping() {
        displayedTitleCount = 0
        let interval = 0.35
        
        for index in 0...fullTitle.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(index)) {
                displayedTitleCount = index
                if index == fullTitle.count {
                    withAnimation(.easeIn(duration: 0.9)) {
                        showTapToBegin = true
                    }
                }
            }
        }
    }
}

private struct RotatingEarthView: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Soft outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.blue.opacity(0.50),
                            Color.purple.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 90,
                        endRadius: 190
                    )
                )
                .blur(radius: 8)
            
            // Earth disc – gradient + fake landmasses that rotate
            ZStack {
                // Base ocean
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.02, green: 0.05, blue: 0.20),
                                Color(red: 0.0, green: 0.25, blue: 0.55)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                // Rotating features (continents + clouds)
                ZStack {
                    // Continents (stylised blobs)
                    Ellipse()
                        .fill(Color(red: 0.0, green: 0.45, blue: 0.25))
                        .frame(width: 120, height: 70)
                        .offset(x: -20, y: -5)
                        .blur(radius: 1.5)
                    
                    Ellipse()
                        .fill(Color(red: 0.0, green: 0.50, blue: 0.28))
                        .frame(width: 80, height: 50)
                        .offset(x: 35, y: 10)
                        .blur(radius: 1.5)
                    
                    Ellipse()
                        .fill(Color(red: 0.0, green: 0.40, blue: 0.20))
                        .frame(width: 60, height: 36)
                        .offset(x: 10, y: -35)
                        .blur(radius: 1.5)
                    
                    // Cloud bands
                    Capsule()
                        .fill(Color.white.opacity(0.55))
                        .frame(width: 160, height: 18)
                        .offset(y: -10)
                        .blur(radius: 6)
                    
                    Capsule()
                        .fill(Color.white.opacity(0.45))
                        .frame(width: 150, height: 16)
                        .offset(y: 22)
                        .blur(radius: 6)
                }
                .rotationEffect(.degrees(rotation))
                
                // Night-side mask
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.black.opacity(0.0),
                                Color.black.opacity(0.8)
                            ],
                            center: .trailing,
                            startRadius: 30,
                            endRadius: 150
                        )
                    )
                
                // Terminator highlight
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.8),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .blur(radius: 3)
            }
            .clipShape(Circle())
        }
        .onAppear {
            // Make rotation more noticeable but still gentle
            withAnimation(.linear(duration: 45).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

