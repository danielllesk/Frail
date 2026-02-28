//
//  NovaController.swift
//  Frail
//
//  Centralized Nova position/state controller.
//  One NovaView is rendered at the AppRootView level;
//  child views call flyTo() to move it.
//

import SwiftUI
import QuartzCore

/// Reports the center of the Nova spacer slot so Nova follows layout changes.
struct NovaSlotPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint { .zero }
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        let next = nextValue()
        if next != .zero {
            value = next
        }
    }
}

@MainActor
final class NovaController: NSObject, ObservableObject {
    // Position & appearance
    @Published var x: CGFloat = 0
    @Published var y: CGFloat = 0
    @Published var size: CGFloat = 48
    @Published var state: NovaState = .idle
    @Published var visible: Bool = false
    
    private nonisolated(unsafe) var displayLink: CADisplayLink?
    private var orbitAngle: Double = 0
    private var orbitCX: CGFloat = 0
    private var orbitCY: CGFloat = 0
    private var orbitR: CGFloat = 0
    private var orbitSpeed: Double = 0.35
    private(set) var isOrbiting: Bool = false
    
    deinit {
        displayLink?.invalidate()
    }
    
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
        orbitSpeed = speed
        orbitAngle = 0
        isOrbiting = true
        
        // Place at initial orbit position
        x = cx + radius
        y = cy
        state = .idle
        verticalOffset = 0
        visible = true
        
        // CADisplayLink fires on vsync, added to main RunLoop
        let link = CADisplayLink(target: self, selector: #selector(orbitTick))
        link.add(to: .main, forMode: .common)
        self.displayLink = link
    }
    
    private var verticalOffset: CGFloat = 0
    
    @objc private func orbitTick(link: CADisplayLink) {
        guard isOrbiting else { return }
        
        // Use delta time for frame-rate independence (target angular speed: orbitSpeed degrees per frame at 60Hz)
        // normalizedSpeed = degrees per second
        let normalizedSpeed = orbitSpeed * 60.0
        let deltaTime = link.targetTimestamp - link.timestamp
        
        orbitAngle += normalizedSpeed * deltaTime
        if orbitAngle >= 360 { orbitAngle -= 360 }
        
        x = orbitCX + orbitR * cos(orbitAngle * .pi / 180)
        y = orbitCY + orbitR * sin(orbitAngle * .pi / 180)
    }
    
    /// Update the orbit center (e.g. when geometry changes).
    func updateOrbitCenter(cx: CGFloat, cy: CGFloat) {
        orbitCX = cx
        orbitCY = cy
    }
    
    /// Stop orbiting.
    func stopOrbit() {
        isOrbiting = false
        displayLink?.invalidate()
        displayLink = nil
    }
    
    /// Hide Nova (used during initial blank phase).
    func hide() {
        visible = false
        stopOrbit()
    }
}
