import SwiftUI

struct WitnessView: View {
    let onBack: () -> Void
    @StateObject private var vm = WitnessViewModel()
    @EnvironmentObject var nova: NovaController
    @State private var shakeOffset: CGFloat = 0
    @State private var nebulaRotation: Double = 0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background is handled by AppRootView globally
                
                // 2. SwiftUI Nebula Layer (Always present, framed better)
                NebulaLayer(opacity: vm.nebulaOpacity, scale: vm.nebulaScale, rotation: nebulaRotation)
                
                // 3. SceneKit Scene
                BinaryStarScene(
                    progress: vm.scrubProgress,
                    isSupernova: vm.isSupernovaTriggered,
                    highlightedStar: vm.highlightedStar
                )
                .ignoresSafeArea()
                
                // 4. Cinematic Supernova Flash
                if vm.showFlash {
                    WitnessSupernovaFlash(shake: $shakeOffset) {
                        withAnimation { vm.showFlash = false }
                    }
                }
                
                // 5. UI Overlay
                InteractionOverlay(vm: vm, onBack: onBack)
                
                // 6. Global Exit Button (Top Left)
                VStack {
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 0.5))
                                )
                                .shadow(color: .black.opacity(0.3), radius: 10)
                        }
                        .padding(.top, 60)
                        .padding(.leading, 24)
                        
                        Spacer()
                    }
                    Spacer()
                }
            }
            .offset(x: shakeOffset)
            .coordinateSpace(name: "appRoot")
            .onAppear {
                vm.start()
                // Slow ambient rotation — Delay by 8s to avoid "image-on-canvas" feel during reveal
                DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
                    withAnimation(.linear(duration: 120).repeatForever(autoreverses: false)) {
                        nebulaRotation = 360
                    }
                }
            }
        }
    }
}

struct InteractionOverlay: View {
    @ObservedObject var vm: WitnessViewModel
    let onBack: () -> Void
    @EnvironmentObject var nova: NovaController
    
    var body: some View {
        VStack {
            // Day Counter (Top Right)
            if vm.currentStep >= 7 && vm.currentStep <= 10 {
                HStack {
                    Spacer()
                    WitnessTimer(dayCount: vm.supernovaDay, isExpanding: vm.isExpanding)
                }
                .padding(.top, 60)
                .padding(.trailing, 24)
            }
            
            Spacer()
            
            if vm.showNovaBubble {
                VStack(spacing: 0) {
                    // 1. Narrative Content Area
                    VStack {
                        HStack(alignment: .top, spacing: 20) {
                            // Nova Slot
                            Color.clear
                                .frame(width: 44, height: 44)
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
                                        
                                        Slider(value: Binding(get: { vm.scrubProgress }, set: { vm.updateScrubProgress($0) }), in: 0...1)
                                            .tint(.frailAccent)
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
        }
    }
}

struct NebulaLayer: View {
    let opacity: Double
    let scale: CGFloat
    let rotation: Double
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1. Ambient Glow — Soft expanded light (using 4K asset)
                Image("crabnebulaBETTER")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width * 2.2, height: geo.size.height * 2.2)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    .rotationEffect(.degrees(rotation * 0.3))
                    .blur(radius: 60)
                    .opacity(opacity * 0.5)
                    .blendMode(.screen)
                    .mask(radialMask(size: geo.size, scale: 2.2))
                
                // 2. Core Structure — Sharp 4K 1:1 asset at optimized scale
                Image("crabnebulaBETTER")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width * scale, height: geo.size.height * scale)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    .rotationEffect(.degrees(rotation))
                    .contrast(1.2)
                    .saturation(1.5)
                    .opacity(opacity)
                    .blendMode(.screen)
                    .mask(radialMask(size: geo.size, scale: scale))
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
    
    // Extreme radial mask with early 20% fade to dissolve rectangular edges
    private func radialMask(size: CGSize, scale: CGFloat) -> some View {
        RadialGradient(
            gradient: Gradient(stops: [
                .init(color: .white, location: 0.0),   
                .init(color: .white, location: 0.2),  // Early fade (20%) for 4K safety
                .init(color: .black.opacity(0.3), location: 0.5), 
                .init(color: .black, location: 0.9)    // Gone long before asset edge
            ]),
            center: .center,
            startRadius: 0,
            endRadius: min(size.width, size.height) * scale * 0.5
        )
        .frame(width: size.width * scale, height: size.height * scale)
    }
}

// MARK: - Cinematic Flash Component

@MainActor
struct WitnessSupernovaFlash: View {
    let onComplete: @MainActor @Sendable () -> Void
    @Binding var shake: CGFloat
    @State private var startTime: Date? = nil
    @State private var flashOpacity: Double = 1.0
    @State private var flashScale: CGFloat = 0.1
    @State private var ringOpacity: Double = 0.0
    @State private var ringScale: CGFloat = 0.1
    private let particles: [WitnessParticle]

    struct WitnessParticle {
        let angle: Double
        let speed: Double
        let size: CGFloat
        let color: Color
        let layer: Int 
    }

    init(shake: Binding<CGFloat>, onComplete: @escaping @MainActor @Sendable () -> Void) {
        self._shake = shake
        self.onComplete = onComplete
        var p: [WitnessParticle] = []
        // Inner white core - Grandiose update
        for _ in 0..<200 { 
            p.append(WitnessParticle(
                angle: Double.random(in: 0...(.pi * 2)),
                speed: Double.random(in: 500...1000), 
                size: CGFloat.random(in: 4...15),
                color: .white,
                layer: 0
            ))
        }
        // Mid orange sparks - More theatric
        for _ in 0..<250 {
            p.append(WitnessParticle(
                angle: Double.random(in: 0...(.pi * 2)),
                speed: Double.random(in: 250...600),
                size: CGFloat.random(in: 3...12),
                color: [Color.orange, Color.yellow, Color.red].randomElement()!,
                layer: 1
            ))
        }
        // Outer blue wisps
        for _ in 0..<150 {
            p.append(WitnessParticle(
                angle: Double.random(in: 0...(.pi * 2)),
                speed: Double.random(in: 150...400),
                size: CGFloat.random(in: 2...10),
                color: [Color.blue, Color.cyan, Color.white].randomElement()!,
                layer: 1
            ))
        }
        self.particles = p
    }

    var body: some View {
        ZStack {
            // Flash core
            Circle()
                .fill(Color.white)
                .frame(width: 40, height: 40)
                .scaleEffect(flashScale)
                .opacity(flashOpacity)
                .blur(radius: 8)

            // Expanding ring
            Circle()
                .stroke(Color.orange.opacity(0.8), lineWidth: 3)
                .frame(width: 200, height: 200)
                .scaleEffect(ringScale)
                .opacity(ringOpacity)
                .blur(radius: 2)

            // Particles
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    guard let start = startTime else { return }
                    let elapsed = timeline.date.timeIntervalSince(start)

                    for p in particles {
                        let distance = p.speed * elapsed
                        let px = size.width/2 + cos(p.angle) * distance
                        let py = size.height/2 + sin(p.angle) * distance
                        let opacity = max(0, 1.0 - (distance / 700))
                        guard opacity > 0 else { continue }

                        let rect = CGRect(
                            x: px - p.size/2,
                            y: py - p.size/2,
                            width: p.size,
                            height: p.size
                        )
                        context.opacity = opacity
                        context.fill(Circle().path(in: rect), with: .color(p.color))
                    }
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            startTime = Date()
            HapticEngine.shared.playSupernova()

            // CAMERA SHAKE OOMPH
            for i in 0..<10 {
                withAnimation(Animation.interactiveSpring().delay(Double(i) * 0.05)) {
                    shake = CGFloat.random(in: -15...15)
                }
            }
            withAnimation(Animation.interactiveSpring().delay(0.5)) {
                shake = 0
            }

            withAnimation(.easeOut(duration: 0.4)) {
                flashScale = 12.0
                flashOpacity = 1.0
            }
            withAnimation(.easeIn(duration: 1.2).delay(0.4)) {
                flashOpacity = 0.0
            }
            withAnimation(.easeOut(duration: 2.5)) {
                ringScale = 6.0
                ringOpacity = 0.6
            }
            withAnimation(.easeIn(duration: 1.5).delay(1.5)) {
                ringOpacity = 0.0
            }
        }
        .task {
            // Native SwiftUI task handles cancellation automatically on view removal
            try? await Task.sleep(nanoseconds: 3_500_000_000)
            onComplete()
        }
    }
}
