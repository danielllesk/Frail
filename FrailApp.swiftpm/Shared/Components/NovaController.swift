//
//  NovaController.swift
//  Frail
//
//  Centralized Nova position/state controller.
//  One NovaView is rendered at the AppRootView level;
//  child views call flyTo() to move it.
//

import SwiftUI

/// Reports the center of the Nova spacer slot so Nova follows layout changes.
struct NovaSlotPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint { .zero }
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

@MainActor
final class NovaController: ObservableObject {
    // Position & appearance
    @Published var x: CGFloat = 0
    @Published var y: CGFloat = 0
    @Published var size: CGFloat = 48
    @Published var state: NovaState = .idle
    @Published var visible: Bool = false
    
    // Orbit
    private var orbitTimer: Timer?
    private var orbitAngle: Double = 0
    private var orbitCX: CGFloat = 0
    private var orbitCY: CGFloat = 0
    private var orbitR: CGFloat = 0
    private var isOrbiting: Bool = false  // guards against Task race
    
    /// Fly Nova to a target position with spring animation.
    func flyTo(
        x: CGFloat,
        y: CGFloat,
        size: CGFloat = 48,
        state: NovaState = .idle,
        animated: Bool = true
    ) {
        stopOrbit()
        if animated {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) {
                self.x = x
                self.y = y
                self.size = size
                self.state = state
                self.visible = true
            }
        } else {
            self.x = x
            self.y = y
            self.size = size
            self.state = state
            self.visible = true
        }
    }
    
    /// Place Nova without animation (initial positioning).
    func place(x: CGFloat, y: CGFloat, size: CGFloat = 48, state: NovaState = .idle) {
        stopOrbit()
        self.x = x
        self.y = y
        self.size = size
        self.state = state
        self.visible = true
    }
    
    /// Start orbiting around a center point.
    func orbitAround(cx: CGFloat, cy: CGFloat, radius: CGFloat, speed: Double = 0.35) {
        stopOrbit()
        
        orbitCX = cx
        orbitCY = cy
        orbitR = radius
        orbitAngle = 0
        isOrbiting = true
        
        // Place at initial orbit position
        x = cx + radius
        y = cy
        state = .idle
        visible = true
        
        orbitTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self, self.isOrbiting else { return }
                self.orbitAngle += speed
                if self.orbitAngle >= 360 {
                    self.orbitAngle -= 360
                }
                self.x = self.orbitCX + self.orbitR * cos(self.orbitAngle * .pi / 180)
                self.y = self.orbitCY + self.orbitR * sin(self.orbitAngle * .pi / 180)
            }
        }
    }
    
    /// Update the orbit center (e.g. when geometry changes).
    func updateOrbitCenter(cx: CGFloat, cy: CGFloat) {
        orbitCX = cx
        orbitCY = cy
    }
    
    /// Stop orbiting.
    func stopOrbit() {
        isOrbiting = false
        orbitTimer?.invalidate()
        orbitTimer = nil
    }
    
    /// Hide Nova (used during initial blank phase).
    func hide() {
        visible = false
        stopOrbit()
    }
}
