//
//  NovaCopy.swift
//  Frail
//
//  Single source of truth for all Nova narration and speech strings.
//

import Foundation

struct NovaCopy {
    
    // MARK: - Intro
    struct Intro {
        static let p1 = "The universe is fragile. If the constants of physics were shifted by a fraction, the stars would never ignite. Atoms would never hold."
        static let p2 = "You would never be here to ask why."
        static let p3 = "I want to show you how delicate this balance really is. Let us look at how it began."
        static let welcome = "Welcome back. The universe is still here, waiting."
    }
    
    // MARK: - Home / Landing
    struct Home {
        static let novaIntro = "I have watched this before. Many times. Most end quickly. This one... this one is different."
    }
    
    // MARK: - Chapter 1: Gravity — The Architect
    struct Gravity {
        static let entry = "One second after the beginning, the universe was a cloud. Hydrogen and helium — the two simplest elements — stretched across billions of kilometres. Evenly spread. No structure. No direction. Just gas, cooling in the dark."
        
        static let lowGravityPrompt = "Gravity is what turns nothing into something. Pull the slider down. See what happens when gravity is too weak to do its work."
        
        static let lowGravity = "Without enough gravity, the cloud never collapses. The gas drifts apart — thinning, cooling, fading into nothing. No stars. No carbon. No chemistry. The universe expands forever and dies without ever becoming anything that wonders about it."
        
        static let highGravityPrompt = "Now push it too far. See the other way this fails."
        
        static let highGravity = "Too much gravity and the collapse is violent. Stars form fast — and burn out faster. A star like our Sun survives for ten billion years. Under high gravity, it survives for millions. Life needs billions of years to emerge. Millions is not enough. The universe becomes briefly bright, then dark forever."
        
        static let rightGravityPrompt = "Now find the value this universe chose. The one that led to stars, to planets, to you."
        
        static let rightGravity = "At this value, the collapse is controlled. Stars ignite and burn steadily for billions of years. Our Sun has been burning for 4.6 billion years and has roughly 5 billion remaining. Long enough for planets to cool. Long enough for chemistry to try, and fail, and try again. Long enough for something to eventually look up."
        
        static let starfield = "Every atom in your body was forged inside one of these stars. The calcium in your bones. The iron in your blood. The oxygen you are breathing right now. Stars made all of it — then died to release it. Gravity made the stars. Gravity made you. It just took several billion years to admit it."
        
        static let closing = "The gravitational constant is 6.674 × 10⁻¹¹ N⋅m²⋅kg⁻². Change it by a few percent in either direction and none of this happens. Remember that number. In Build, gravity will be yours to choose. I have seen what happens when you don't choose carefully."
    }
    
    // MARK: - Chapter 2: Light Speed — The Weaver
    struct LightSpeed {
        static let entry = "Inside those stars, something smaller was happening. Atoms were being built. Carbon. Oxygen. Iron. The ingredients of everything alive."
        
        static let normalAtom = "This is a Carbon atom. Six protons, six neutrons, six electrons. It is the foundation of all life. It exists because the speed of light allows it."
        
        static let lowLightPrompt = "Light speed is the weaver of matter. Slow it down. Watch how it changes the strength of the bond."
        
        static let lowLight = "Too slow. The fine-structure constant shifts. Atoms shrink, becoming too tightly bound to react. Chemistry reaches a dead end. No molecules. No life. No story."
        
        static let highLightPrompt = "Now push it too far. See how matter responds to violent energy."
        
        static let highLight = "Too fast. The atom becomes violently energetic. Electrons move so quickly that chemical bonds cannot form. Matter becomes too volatile for life."
        
        static let rightLightPrompt = "Find the value this universe chose. The speed that allowed matter to hold."
        
        static let rightLight = "At this value—exactly this—atoms hold. Molecules form. Carbon bonds to oxygen bonds to hydrogen. The instructions for life become writable. Our bodies are made of matter that holds. Most matter, in most possible universes, does not."
        
        static let starfield = "And then the star dies. It swells, reddens, and prepares its gift. Every atom it forged—every piece of you—is about to be released."
        
        static let closing = "You are made of dead stars. The speed of light decided they could make something worth dying for."
    }
    
    // MARK: - Learn — Lesson 3: The Flow of Time
    struct Time {
        static let entry = "Gravity gave us the stars. Light speed wove them into atoms. But a story needs more than actors and a stage—it needs a heartbeat. It needs time."
        
        static let setup = "Meet Alice and Bob. They are young, the universe at their feet. They start here, on Earth, at the same moment. But we are about to divide their futures. Bob will stay. Alice will go."
        
        static let velocityPrompt = "Time is not a rigid line; it is a fluid, a fabric that stretches when you move. Pull the slider to accelerate Alice. At first, the difference is a whisper—a heartbeat lost here and there."
        
        static let highVelocity = "Now look at them. Alice is moving at 99% of the speed of light. To her, time feels normal. She breathes, thinks, and dreams at the same pace. But look at Bob's clock. On Earth, years are screaming past. For every year Alice spends in the dark, seven years pass for Bob. His hair is greying. His children are growing. She is falling through his future like a stone."
        
        static let reunionPrompt = "Eventually, every journey must end. Bring the velocity back to zero. Bring Alice home to see what she has paid for her speed."
        
        static let reunion = "The gap is permanent. Alice remains in her prime, while Bob has lived a lifetime. This is the fundamental cost of the universe's geometry. Space and time are one thing—Space-Time. If you take more of one, you have less of the other."
        
        static let closing = "Why does this matter? Because in your future, when you Build universes or reach for distant suns, you will not just be navigating distance. You will be navigating time. The stars are far, and our lives are short, but the weaver allows us a loophole. Remember this. Simplicity became complexity because time allowed it to breathe."
        
        static func slider(at multiplier: Double) -> String {
            switch multiplier {
            case ..<0.3:
                return "A walk in the sun. The divergence is subtle, almost invisible."
            case 0.3..<0.8:
                return "The stretch becomes a tear. Bob is beginning to age faster."
            case 0.8..<0.95:
                return "Extreme dilation. Alice is now significantly younger than her twin."
            default:
                return "The threshold. Time for Alice has practically stopped."
            }
        }
        
        static let summary = "Time provides the duration required for simplicity to become complexity."
    }
    
    // Compatibility for TimeDilationView
    struct TimeDilation {
        static let entry = Time.entry
        static func slider(at: Double) -> String { Time.slider(at: at) }
        static let summary = Time.summary
    }
}
