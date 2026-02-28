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
        static let entry = "Gravity built the stars. Light speed built the atoms. But complexity — life, thought, everything that wonders — requires something neither of those provides. It requires duration. The universe needed to be old enough for any of this to matter. Time is not the background. It is the third constant."
        
        static let setup = "Meet Alice and Bob. They start here, on Earth, at the same moment — the same age, the same future. We are about to divide them. Bob will stay. Alice will go. What happens next is not science fiction."
        
        static let velocityPrompt = "Move Alice. Slowly at first. Watch both clocks. What you are about to see is not an optical illusion, not a measurement error. It is the geometry of the universe behaving exactly as it must. This happens because space and time are not separate. They are one thing. Moving through one means moving less through the other."
        
        static let highVelocity = "Now look at them. Alice is moving at 99% of the speed of light. To her, everything feels normal — she breathes, thinks, dreams at the same pace she always has. But look at Bob's clock. On Earth, years are screaming past. For every year Alice spends in the dark, seven pass for Bob. His hair is greying. His children are growing. She is falling through his future like a stone."
        
        static let reunionPrompt = "Every journey ends. Bring Alice home. Bring the velocity back to zero and see what her speed has cost her."
        
        static let reunion = "The gap is permanent. This is not a trick. Alice did not experience time incorrectly — she experienced less of it. Here is why: everything moves through spacetime at exactly the speed of light. Always. If Alice uses that speed to move through space, she has less of it left to move through time. Speed through space steals time. The faster you run, the slower you age. The universe does not bend this rule. It is the rule."
        
        static let closing = "Why does this matter? Because the stars are far and our lives are short. Time dilation is not a curiosity — it is a feature of the universe that makes the cosmos navigable. The constants you have seen are not arbitrary. Gravity, light speed, time — each one precise. Each one load-bearing. Remove any one of them and there is no story. You are the proof that they held."
        
        static func slider(at multiplier: Double) -> String {
            switch multiplier {
            case ..<0.3:
                return "Almost no effect. The divergence is too small to feel."
            case 0.3..<0.7:
                return "The clocks are separating. Bob is aging faster."
            case 0.7..<0.94:
                return "Significant dilation. Alice is accumulating younger moments."
            default:
                return "Near the limit. For every year Alice lives, seven pass for Bob."
            }
        }
        
        static let summary = "Three constants. Gravity, light speed, time. Each precise. Each load-bearing. You have seen all three. Now build something with them."
    }
    
    // Compatibility for TimeDilationView
    struct TimeDilation {
        static let entry = Time.entry
        static func slider(at: Double) -> String { Time.slider(at: at) }
        static let summary = Time.summary
    }
}
