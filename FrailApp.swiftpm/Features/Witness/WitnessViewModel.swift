import SwiftUI
import Combine

@MainActor
class WitnessViewModel: ObservableObject {
    @Published var currentStep: Int = 0
    @Published var scrubProgress: Double = 0.0
    @Published var novaText: String = ""
    @Published var showNovaBubble: Bool = true
    @Published var highlightedStar: String? = nil
    
    // Supernova/Timer states
    @Published var isSupernovaTriggered = false
    @Published var isExpanding = false
    @Published var supernovaDay = 0
    @Published var showContinue: Bool = false
    
    // Cinematic State
    @Published var showFlash = false
    @Published var showNebula = false
    @Published var nebulaOpacity: Double = 0.0
    @Published var nebulaScale: CGFloat = 0.9
    
    // Step Mapping
    struct StepData {
        let text: String
        let progress: Double
        let isSlider: Bool
        let focus: String?
    }
    
    private var steps: [StepData] {
        [
            StepData(text: NovaCopy.Witness.intro, progress: 0.0, isSlider: false, focus: nil), // 0
            StepData(text: NovaCopy.Witness.naming, progress: 0.0, isSlider: false, focus: nil), // 1
            StepData(text: NovaCopy.Witness.starA, progress: 0.0, isSlider: false, focus: "starA"), // 2
            StepData(text: NovaCopy.Witness.starB, progress: 0.0, isSlider: false, focus: "starB"), // 3
            StepData(text: NovaCopy.Witness.starBClose, progress: 0.0, isSlider: false, focus: "starB"), // 4
            StepData(text: NovaCopy.Witness.approach30, progress: 0.3, isSlider: true, focus: nil), // 5 (Slider Start)
            StepData(text: NovaCopy.Witness.flash, progress: 1.0, isSlider: false, focus: nil), // 6 (Explosion Phase)
            StepData(text: NovaCopy.Witness.hubble, progress: 1.0, isSlider: false, focus: nil), // 7
            StepData(text: NovaCopy.Witness.yangWeide, progress: 1.0, isSlider: false, focus: nil), // 8
            StepData(text: NovaCopy.Witness.lightDelay, progress: 1.0, isSlider: false, focus: nil), // 9
            StepData(text: NovaCopy.Witness.expanding, progress: 1.0, isSlider: false, focus: nil), // 10
            StepData(text: NovaCopy.Witness.closing, progress: 1.0, isSlider: false, focus: nil), // 11
            StepData(text: NovaCopy.Witness.thesis, progress: 1.0, isSlider: false, focus: nil) // 12
        ]
    }
    
    init() {
        syncStep()
    }
    
    func start() {
        currentStep = 0
        scrubProgress = 0.0
        isSupernovaTriggered = false
        isExpanding = false
        supernovaDay = 0
        showContinue = false
        showFlash = false
        showNebula = false
        nebulaOpacity = 0.0
        nebulaScale = 0.9
        syncStep()
    }
    
    // MARK: - Navigation
    
    var hasNext: Bool {
        !isSliderPhase && currentStep < steps.count - 1
    }
    
    var hasBack: Bool {
        currentStep > 0
    }
    
    var isSliderPhase: Bool {
        steps[currentStep].isSlider
    }
    
    func next() {
        if currentStep < steps.count - 1 {
            currentStep += 1
            syncStep()
        }
    }
    
    func back() {
        if currentStep > 0 {
            currentStep -= 1
            if currentStep <= 5 {
                scrubProgress = steps[currentStep].progress
            }
            syncStep()
        }
    }
    
    private func syncStep() {
        let data = steps[currentStep]
        novaText = data.text
        highlightedStar = data.focus
        
        if !data.isSlider {
            withAnimation(.spring()) {
                scrubProgress = data.progress
            }
        }
        
        // Supernova state management
        if currentStep >= 6 {
            if !isSupernovaTriggered { triggerSupernova() }
            updateSupernovaNarrative()
        } else {
            isSupernovaTriggered = false
            showNebula = false
            showFlash = false
        }
        
        if currentStep == steps.count - 1 {
            showContinue = true
        }
    }
    
    private func triggerSupernova() {
        isSupernovaTriggered = true
        withAnimation { showFlash = true }
        
        // Initial state for materialization
        self.nebulaOpacity = 0
        self.nebulaScale = 0.8
        
        Task {
            try? await Task.sleep(nanoseconds: 3_500_000_000)
            if Task.isCancelled { return }
            
            withAnimation(.easeOut) { self.showFlash = false }
            self.showNebula = true
            
            // Slow dramatic fade — 6 seconds feels cinematic (Targeting 1.6x for 4K quality)
            withAnimation(.easeIn(duration: 6.0)) {
                self.nebulaOpacity = 0.9
                self.nebulaScale = 1.6
            }
        }
    }
    
    private func updateSupernovaNarrative() {
        // Sync days to steps
        switch currentStep {
        case 8: supernovaDay = 3; isExpanding = false
        case 9: supernovaDay = 10; isExpanding = false
        case 10...12: supernovaDay = 23; isExpanding = true
        default: supernovaDay = 1; isExpanding = false
        }
    }
    
    // MARK: - Interaction
    
    func updateScrubProgress(_ value: Double) {
        guard isSliderPhase else { return }
        scrubProgress = value
        
        // Git-style narrative updates during slider
        if value >= 0.85 {
            novaText = NovaCopy.Witness.inevitable
        } else if value >= 0.75 {
            novaText = NovaCopy.Witness.approach85
        } else if value >= 0.5 {
            novaText = NovaCopy.Witness.approach60
        } else {
            novaText = NovaCopy.Witness.approach30
        }
        
        if value >= 0.95 {
            next()
        }
    }
}
