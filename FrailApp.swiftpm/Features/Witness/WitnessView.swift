//
//  WitnessView.swift
//  Frail
//

import SwiftUI

struct WitnessView: View {
    let onBack: () -> Void
    @StateObject private var vm = WitnessViewModel()
    @EnvironmentObject var nova: NovaController
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1. Background 3D Scene
                BinaryStarScene(
                    progress: vm.scrubProgress,
                    isSupernova: vm.isSupernovaTriggered,
                    highlightedStar: vm.highlightedStar
                )
                    .ignoresSafeArea()
                    .opacity(vm.isExpanding ? 0.3 : 1.0)
                
                // 2. Cinematic Overlays (Now integrated into BinaryStarScene)
                // SupernovaRevealView is removed in favor of 3D SceneKit rendering.
                
                if vm.currentStep >= 8 && vm.currentStep <= 10 {
                    VStack {
                        HStack {
                            Spacer()
                            WitnessTimer(dayCount: vm.supernovaDay, isExpanding: vm.isExpanding)
                        }
                        .padding(.top, 80)
                        .padding(.trailing, 24)
                        Spacer()
                    }
                }
                
                VStack(spacing: 0) {
                    // Header (Glassy minimalist)
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.frailPrimaryText)
                                .padding(12)
                                .background(Circle().fill(Color.black.opacity(0.3)))
                        }
                        Spacer()
                        Text("THE SPECTACLE")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.frailGold)
                            .tracking(4)
                        Spacer()
                        Color.clear.frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    
                    Spacer()
                    
                    // UNIFIED NARRATIVE PANEL
                    VStack(spacing: 0) {
                        // 1. Content Area (Nova + Text)
                        HStack(alignment: .top, spacing: 16) {
                            // Nova Avatar Slot
                            Color.clear
                                .frame(width: 54, height: 54)
                                .overlay(
                                    GeometryReader { slotGeo in
                                        Color.clear.preference(
                                            key: NovaSlotPreferenceKey.self,
                                            value: slotGeo.frame(in: .named("appRoot")).center
                                        )
                                    }
                                )
                                .background(
                                    Circle()
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        .background(Circle().fill(Color.black.opacity(0.2)))
                                )
                            
                            VStack(alignment: .leading, spacing: 8) {
                                TypewriterText(text: vm.novaText, speed: 0.035)
                                    .id("\(vm.currentStep)_\(vm.novaText)") // GUARANTEED RESET
                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                                    .lineSpacing(6)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(minHeight: 80, alignment: .topLeading)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 16)
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.horizontal, 24)
                        
                        // 2. Control Area (Nav Buttons / Slider)
                        ZStack {
                            if vm.isSliderPhase {
                                // Slider Phase
                                HStack(spacing: 16) {
                                    if vm.hasBack {
                                        Button(action: { vm.back() }) {
                                            Image(systemName: "arrow.left")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.white.opacity(0.7))
                                                .padding(12)
                                                .background(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("TIME CONTROL — PULL TO COLLIDE")
                                            .font(.system(size: 9, weight: .black))
                                            .foregroundColor(.frailGold.opacity(0.8))
                                            .tracking(1)
                                        
                                        Slider(value: $vm.scrubProgress, in: 0...1)
                                            .tint(.frailAccent)
                                            .onChange(of: vm.scrubProgress) { newValue in
                                                vm.updateScrubProgress(newValue)
                                            }
                                    }
                                    
                                    Text("\(Int(vm.scrubProgress * 100))%")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(.frailGold)
                                        .frame(width: 35)
                                }
                                .transition(.opacity)
                            } else {
                                // Step-Based Navigation
                                HStack {
                                    if vm.hasBack {
                                        Button(action: { vm.back() }) {
                                            HStack(spacing: 6) {
                                                Image(systemName: "arrow.left")
                                                Text("Prev")
                                            }
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white.opacity(0.6))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1))
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    if vm.hasNext {
                                        Button(action: { vm.next() }) {
                                            HStack(spacing: 6) {
                                                Text("Next")
                                                Image(systemName: "arrow.right")
                                            }
                                            .font(.system(size: 15, weight: .heavy))
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 28)
                                            .padding(.vertical, 12)
                                            .background(Capsule().fill(Color.white))
                                            .shadow(color: .white.opacity(0.2), radius: 8)
                                        }
                                    }
                                    
                                    if vm.showContinue {
                                        Button(action: onBack) {
                                            Text("Finish Journey")
                                                .font(.system(size: 15, weight: .black))
                                                .foregroundColor(.black)
                                                .padding(.horizontal, 28)
                                                .padding(.vertical, 12)
                                                .background(Capsule().fill(Color.frailGold))
                                                .shadow(color: .frailGold.opacity(0.4), radius: 10)
                                        }
                                    }
                                }
                                .transition(.opacity)
                            }
                        }
                        .padding(24)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .fill(Color.black.opacity(0.6))
                            .background(
                                RoundedRectangle(cornerRadius: 32, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .opacity(0.8)
                            )
                            .overlay(RoundedRectangle(cornerRadius: 32, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 0.5))
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                    .onPreferenceChange(NovaSlotPreferenceKey.self) { pos in
                        if pos != .zero {
                            nova.flyTo(x: pos.x, y: pos.y, size: 54, state: .speaking)
                        }
                    }
                }
            }
            .onAppear {
                vm.start()
            }
            .onDisappear {
                // Task cancellation is now handled by StateObject lifecycle
            }
        }
    }
}
