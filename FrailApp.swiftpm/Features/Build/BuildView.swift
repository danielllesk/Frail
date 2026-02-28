//
//  BuildView.swift
//  Frail
//
//  The main Universe Builder interface.
//

import SwiftUI
import UIKit

struct BuildView: View {
    let onBack: () -> Void
    @StateObject private var vm = BuildViewModel()
    @EnvironmentObject var nova: NovaController
    
    var body: some View {
        ZStack {
            // ── 3D Scene Background ──
            SolarSystemScene(
                gravity: vm.gravity,
                lightSpeed: vm.lightSpeed,
                starType: vm.starType,
                planets: vm.planets,
                zoomScale: vm.zoomScale,
                universeName: vm.universeName
            )
            .ignoresSafeArea()
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        let delta = value / (context.lastScale ?? 1.0)
                        vm.zoomScale = max(0.2, min(3.0, vm.zoomScale * delta))
                        context.lastScale = value
                    }
                    .onEnded { _ in
                        context.lastScale = nil
                    }
            )
            
            // ── Overlays ──
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.frailPrimaryText)
                            .padding(12)
                            .background(Circle().fill(Color.frailMentorBg.opacity(0.4)))
                    }
                    .contentShape(Rectangle())
                    .allowsHitTesting(true)
                    .zIndex(10)
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("STABILITY SCORE")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.frailMutedText)
                            .tracking(1)
                        Text("\(Int(vm.stabilityScore))")
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundColor(Verdict.from(score: vm.stabilityScore).color)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // Nova Onboarding Bubble
                if vm.showOnboarding {
                    HStack {
                        Spacer()
                        novaOnboardingBubble
                            .frame(maxWidth: 320)
                            .padding(.top, 40) // Move down
                            .padding(.trailing, 20) // Move right
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
                
                Spacer()
                
                // Controls Panel
                VStack(spacing: 16) {
                    // Universe Name Input
                    HStack {
                        Image(systemName: "pencil")
                            .foregroundColor(.frailMutedText)
                        TextField("Universe Name", text: $vm.universeName)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.frailPrimaryText)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Category Picker
                    HStack(spacing: 0) {
                        ForEach(BuildViewModel.BuildCategory.allCases) { cat in
                            Button(action: { vm.selectedCategory = cat }) {
                                Text(cat.rawValue)
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(vm.selectedCategory == cat ? .frailBackground : .frailPrimaryText)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(vm.selectedCategory == cat ? Color.frailAccent : Color.clear)
                                    )
                            }
                        }
                    }
                    .padding(4)
                    .background(Color.frailMentorBg.opacity(0.8))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    // Sliders Area
                    VStack(spacing: 20) {
                        if vm.selectedCategory == .constants {
                            BuildSlider(
                                label: "Gravity",
                                value: $vm.gravity,
                                range: PhysicsConstants.Universal.gravityRange,
                                format: "%.1f",
                                onChange: { vm.updateScore() }
                            )
                            
                            BuildSlider(
                                label: "Speed of Light",
                                value: $vm.lightSpeed,
                                range: PhysicsConstants.Universal.lightSpeedRange,
                                format: "%.1f",
                                onChange: { vm.updateScore() }
                            )
                            
                            StarTypePicker(selected: $vm.starType, onChange: { vm.updateScore() })
                        } else {
                            // Planet Sliders
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(spacing: 20) {
                                    ForEach(0..<vm.planets.count, id: \.self) { i in
                                        VStack(alignment: .leading, spacing: 12) {
                                            Text("PLANET \(i + 1)")
                                                .font(.system(size: 10, weight: .black))
                                                .foregroundColor(.frailGold)
                                                .tracking(2)
                                            
                                            BuildSlider(
                                                label: "Mass",
                                                value: $vm.planets[i].mass,
                                                range: PhysicsConstants.Planets.massRange,
                                                format: "%.1f",
                                                onChange: { vm.updateScore() }
                                            )
                                            
                                            BuildSlider(
                                                label: "Orbit Radius",
                                                value: $vm.planets[i].orbitalRadius,
                                                range: PhysicsConstants.Planets.orbitRange,
                                                format: "%.1f AU",
                                                onChange: { vm.updateScore() }
                                            )
                                        }
                                        .padding(16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.frailMentorBg.opacity(0.4))
                                        )
                                    }
                                }
                                .padding(.bottom, 10)
                            }
                            .frame(maxHeight: 250)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Simulate Button
                    Button(action: { vm.simulate() }) {
                        Text("Simulate Stability")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.frailBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.frailAccent)
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .cornerRadius(32, corners: [.topLeft, .topRight])
                        .ignoresSafeArea()
                )
            }
            
            // Verdict Overlay
            if vm.showVerdict {
                VerdictView(
                    score: vm.stabilityScore,
                    reason: vm.failureReason,
                    universeName: vm.universeName,
                    onClose: { vm.showVerdict = false },
                    onShowOptimal: { 
                        vm.showVerdict = false
                        vm.showOptimal()
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 1.1)))
            }
        }
        .onAppear {
            // Nova follows the Slot Preference Key in novaOnboardingBubble
        }
        .onChange(of: vm.showOnboarding) { show in
            if !show {
                // Stay in the same spot as the onboarding slot
                // (which was roughly x: 300, y: 150 on iPhone, but we use the pref key)
            }
        }
    }
    
    // MARK: - Sub-views
    
    private var novaOnboardingBubble: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 10) {
                Text("“Here is a clean slate. Find a stable system. Choose its constants, set its foundations, and see if you can create a universe that endures.”")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.frailPrimaryText)
                    .lineSpacing(2)
                
                Button(action: { vm.dismissOnboarding() }) {
                    Text("I've got this")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.frailAccent)
                        .padding(.vertical, 4)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.frailMentorBg.opacity(0.9))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.frailMentorBorder, lineWidth: 1))
            )

            // Nova slot (moved to right)
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
        }
        .onPreferenceChange(NovaSlotPreferenceKey.self) { pos in
            if pos != .zero {
                // Nova stays pinned to this slot whether onboarding is shown or just finished
                // If showOnboarding is true, use .speaking, else .idle
                nova.flyTo(x: pos.x, y: pos.y, size: 48, state: vm.showOnboarding ? .speaking : .idle)
            }
        }
    }
    
    @State private var context = Context()
    class Context {
        var lastScale: CGFloat?
    }
}

// MARK: - Components

struct BuildSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let format: String
    let onChange: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(label.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.frailMutedText)
                    .tracking(1)
                Spacer()
                Text(String(format: format, value))
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.frailGold)
            }
            
            Slider(value: $value, in: range)
                .tint(.frailAccent)
                .onChange(of: value) { _ in
                    onChange()
                }
        }
    }
}

struct StarTypePicker: View {
    @Binding var selected: PhysicsConstants.StarType
    let onChange: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("STAR TYPE")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.frailMutedText)
                .tracking(1)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(PhysicsConstants.StarType.allCases, id: \.self) { (type: PhysicsConstants.StarType) in
                        Button(action: { 
                            selected = type
                            onChange()
                        }) {
                            VStack(spacing: 6) {
                                Circle()
                                    .fill(Color(uiColor: type.starColor))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: selected == type ? 2 : 0)
                                    )
                                
                                Text(type.rawValue)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(selected == type ? .frailPrimaryText : .frailMutedText)
                            }
                            .frame(width: 70)
                        }
                    }
                }
            }
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
