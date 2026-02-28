//
//  WitnessViewModel.swift
//  Frail
//
//  State for the galaxy collision witness experience.
//

import SwiftUI

@MainActor
final class WitnessViewModel: ObservableObject {
    @Published var currentStep: Int = 0
    @Published var scrubProgress: Double = 0.0 // Slider value (0.0 to 1.0)
    @Published var showNovaBubble: Bool = false
    @Published var novaText: String = ""
    
    // Supernova/Timer states
    @Published var isSupernovaTriggered: Bool = false
    @Published var supernovaDay: Int = 1
    @Published var isExpanding: Bool = false
    @Published var showContinue: Bool = false
    
    // Camera / Focus states
    @Published var highlightedStar: String? = nil // "starA", "starB", or nil
    
    init() {
        self.novaText = NovaCopy.Witness.intro
        syncStep()
    }
    
    // MARK: - Step Mapping
    
    struct StepData {
        let text: String
        let progress: Double
        let isSlider: Bool
        let focus: String?
    }
    
    private var steps: [StepData] {
        [
            StepData(text: NovaCopy.Witness.intro, progress: 0.0, isSlider: false, focus: nil), // 0
            StepData(text: NovaCopy.Witness.naming, progress: 0.05, isSlider: false, focus: nil), // 1
            StepData(text: NovaCopy.Witness.starA, progress: 0.1, isSlider: false, focus: "starA"), // 2
            StepData(text: NovaCopy.Witness.starB, progress: 0.2, isSlider: false, focus: "starB"), // 3
            StepData(text: NovaCopy.Witness.starBClose, progress: 0.3, isSlider: false, focus: "starB"), // 4
            StepData(text: NovaCopy.Witness.approach30, progress: 0.3, isSlider: true, focus: nil), // 5 (Slider)
            StepData(text: NovaCopy.Witness.flash, progress: 1.0, isSlider: false, focus: nil), // 6 (Supernova)
            StepData(text: NovaCopy.Witness.hubble, progress: 1.0, isSlider: false, focus: nil), // 7
            StepData(text: NovaCopy.Witness.yangWeide, progress: 1.0, isSlider: false, focus: nil), // 8
            StepData(text: NovaCopy.Witness.lightDelay, progress: 1.0, isSlider: false, focus: nil), // 9
            StepData(text: NovaCopy.Witness.expanding, progress: 1.0, isSlider: false, focus: nil), // 10
            StepData(text: NovaCopy.Witness.closing, progress: 1.0, isSlider: false, focus: nil), // 11
            StepData(text: NovaCopy.Witness.thesis, progress: 1.0, isSlider: false, focus: nil) // 12
        ]
    }
    
    var isSliderPhase: Bool { currentStep == 5 }
    var hasBack: Bool { currentStep > 0 && !isSupernovaTriggered }
    var hasNext: Bool { !isSliderPhase && currentStep < steps.count - 1 }
    
    // MARK: - Navigation
    
    func start() {
        // No-op if already synced in init, but ensures state is reset
        currentStep = 0
        syncStep()
        showNovaBubble = true
    }
    
    func next() {
        guard currentStep < steps.count - 1 else { return }
        currentStep += 1
        syncStep()
    }
    
    func back() {
        guard currentStep > 0 else { return }
        currentStep -= 1
        
        // CRITICAL: Reset scrub progress when going back into/before slider phase
        // to prevent the 1.0 threshold from immediately calling next() again.
        if currentStep <= 5 {
            scrubProgress = 0.0
        }
        
        syncStep()
    }
    
    private func syncStep() {
        let data = steps[currentStep]
        novaText = data.text
        highlightedStar = data.focus
        
        // Update Scene Progress (except during slider)
        if !data.isSlider {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                scrubProgress = data.progress
            }
        }
        
        // Supernova Logic
        if currentStep >= 6 {
            triggerSupernova()
        } else {
            isSupernovaTriggered = false
            showContinue = false
            isExpanding = false
        }
        
        if currentStep == steps.count - 1 {
            showContinue = true
        }
    }
    
    // MARK: - Slider Logic
    
    func updateScrubProgress(_ value: Double) {
        guard isSliderPhase else { return }
        scrubProgress = value
        
        // Synchronized Text Cues
        if value >= 0.85 {
            novaText = NovaCopy.Witness.inevitable
        } else if value >= 0.75 {
            novaText = NovaCopy.Witness.approach85
        } else if value >= 0.5 {
            novaText = NovaCopy.Witness.approach60
        } else {
            novaText = NovaCopy.Witness.approach30
        }
        
        // AUTO-ADVANCE once only
        if value >= 1.0 && currentStep == 5 {
            next()
        }
    }
    
    private func triggerSupernova() {
        isSupernovaTriggered = true
        
        // Days synced to narrative (based on 1054 AD records)
        if currentStep == 8 {
            supernovaDay = 3
        } else if currentStep == 9 {
            supernovaDay = 10
        } else if currentStep >= 10 {
            supernovaDay = 23
            isExpanding = true
        } else {
            supernovaDay = 1
            isExpanding = false
        }
    }
}
