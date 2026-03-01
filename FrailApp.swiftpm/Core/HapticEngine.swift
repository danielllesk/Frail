//
//  HapticEngine.swift
//  Frail
//
//  CoreHaptics wrapper, all patterns defined here
//

import CoreHaptics
import UIKit

@MainActor
final class HapticEngine {
    static let shared = HapticEngine()
    
    /// Notification fired when a haptic is requested, for visual debugging on simulator
    static let hapticDebugFired = Notification.Name("hapticDebugFired")
    
    private var engine: CHHapticEngine?
    
    private init() {
        createEngine()
    }
    
    private func createEngine() {
        #if targetEnvironment(simulator)
        return // CoreHaptics doesn't run on simulator
        #else
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic engine creation error: \(error)")
        }
        #endif
    }
    
    private func notifyDebug(_ intensity: Float = 0.5) {
        #if targetEnvironment(simulator)
        NotificationCenter.default.post(name: HapticEngine.hapticDebugFired, object: intensity)
        #endif
    }
    
    // MARK: - Named Patterns
    
    func playSliderMove(intensity: Float) {
        notifyDebug(intensity)
        guard let engine = engine else { return }
        
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            ],
            relativeTime: 0,
            duration: 0.1
        )
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Slider haptic error: \(error)")
        }
    }
    
    func playTimeDilationPulse(velocity: Double) {
        notifyDebug(0.4)
        guard let engine = engine else { return }
        
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            ],
            relativeTime: 0
        )
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Time dilation haptic error: \(error)")
        }
    }
    
    func playGravityIntensity(multiplier: Double) {
        let intensity = Float(multiplier / 5.0).clamped(to: 0...1)
        playSliderMove(intensity: intensity)
    }
    
    func playApplyConstants() {
        notifyDebug(0.8)
        guard let engine = engine else { return }
        
        let sharp = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
            ],
            relativeTime: 0
        )
        
        let impact = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            ],
            relativeTime: 0.1
        )
        
        do {
            let pattern = try CHHapticPattern(events: [sharp, impact], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Apply constants haptic error: \(error)")
        }
    }
    
    func playVerdictStable() {
        notifyDebug(0.7)
        guard let engine = engine else { return }
        
        var events: [CHHapticEvent] = []
        for i in 0..<3 {
            let intensity = Float(0.3 + Double(i) * 0.2)
            events.append(
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                    ],
                    relativeTime: Double(i) * 0.15
                )
            )
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Stable verdict haptic error: \(error)")
        }
    }
    
    func playVerdictCollapse() {
        notifyDebug(1.0)
        guard let engine = engine else { return }
        
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            ],
            relativeTime: 0
        )
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Collapse verdict haptic error: \(error)")
        }
    }
    
    func playSuccess() {
        playVerdictStable()
    }
    
    func playWarning() {
        playVerdictCollapse()
    }
    
    func playNovaSpeak() {
        notifyDebug(0.3)
        guard let engine = engine else { return }
        
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.2),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
            ],
            relativeTime: 0
        )
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Nova speak haptic error: \(error)")
        }
    }
    
    func playLessonComplete() {
        notifyDebug(0.9)
        guard let engine = engine else { return }
        
        let soft1 = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
            ],
            relativeTime: 0
        )
        
        let soft2 = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
            ],
            relativeTime: 0.15
        )
        
        let firm = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
            ],
            relativeTime: 0.3
        )
        
        do {
            let pattern = try CHHapticPattern(events: [soft1, soft2, firm], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Lesson complete haptic error: \(error)")
        }
    }
    
    func playChallengeCorrect() {
        notifyDebug(0.6)
        guard let engine = engine else { return }
        
        let tap1 = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            ],
            relativeTime: 0
        )
        
        let tap2 = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            ],
            relativeTime: 0.1
        )
        
        do {
            let pattern = try CHHapticPattern(events: [tap1, tap2], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Challenge correct haptic error: \(error)")
        }
    }
    
    func playChallengeWrong() {
        notifyDebug(0.6)
        guard let engine = engine else { return }
        
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
            ],
            relativeTime: 0
        )
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Challenge wrong haptic error: \(error)")
        }
    }
    
    func playSupernova() {
        notifyDebug(1.0)
        guard let engine = engine else { return }
        
        // Multi-stage explosion impact
        let peak = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
            ],
            relativeTime: 0
        )
        
        let echo = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
            ],
            relativeTime: 0.1
        )
        
        do {
            let pattern = try CHHapticPattern(events: [peak, echo], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Supernova haptic error: \(error)")
        }
    }
}

extension Float {
    func clamped(to range: ClosedRange<Float>) -> Float {
        return Swift.max(range.lowerBound, Swift.min(range.upperBound, self))
    }
}
