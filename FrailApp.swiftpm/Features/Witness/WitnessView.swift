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
                // ── Background 3D Scene ──
                CollisionScene(progress: vm.scrubProgress)
                    .ignoresSafeArea()
                
                VStack {
                    // Header
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.frailPrimaryText)
                        }
                        Spacer()
                        Text("Witness")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.frailGold)
                            .tracking(3)
                        Spacer()
                        Color.clear.frame(width: 24, height: 24)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Content Area
                    VStack(spacing: 32) {
                        // Poetic Line (Nova)
                        Text(vm.currentNovaLine)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.frailPrimaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .frame(height: 80)
                        
                        // Scrub Slider
                        VStack(spacing: 12) {
                            HStack {
                                Text("100 MILLION YEARS AGO")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.frailMutedText)
                                Spacer()
                                Text("PRESENT DAY")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.frailMutedText)
                            }
                            .padding(.horizontal, 4)
                            
                            Slider(value: $vm.scrubProgress, in: 0...1)
                                .tint(.frailAccent)
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.ultraThinMaterial)
                        )
                        .padding(.horizontal, 24)
                        .padding(.bottom, 48)
                    }
                }
            }
            .onAppear {
                nova.flyTo(x: geo.size.width / 2, y: 150, state: .idle)
            }
        }
    }
}
