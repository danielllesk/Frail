//
//  NovaCopy.swift
//  Frail
//
//  ALL hardcoded Nova strings, organized by context
//  Single source of truth for all text
//

import Foundation

struct NovaCopy {
    // MARK: - Intro
    struct Intro {
        static let welcome = "Welcome to Frail. The universe awaits."
    }
    
    // MARK: - Home
    struct Home {
        static let novaIntro = "I am Nova. I observe. I will guide you through the forces that hold — or break — everything."
    }
    
    // MARK: - Learn — Lesson 1: Time Dilation
    struct TimeDilation {
        static let entry = "Two people. One rocket. One planet. The same moment — experienced differently."
        
        static func slider(at velocity: Double) -> String {
            if velocity < 0.05 {
                return "At rest, their clocks agree. Time flows at the same rate for both."
            } else if velocity < 0.3 {
                return "Alice accelerates. Her clock begins to lag. A few seconds lost per year."
            } else if velocity < 0.6 {
                return "Half the speed of light. Alice ages noticeably slower. Bob grows old faster."
            } else if velocity < 0.85 {
                return "Time for Alice nearly stops relative to Bob. She travels years. He lives decades."
            } else {
                return "Close to light speed. Alice barely ages. For Bob, generations may pass."
            }
        }
        
        static let summary = "This is not science fiction. It is time dilation — confirmed by atomic clocks on aircraft. Speed warps time itself."
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
    
    // MARK: - Learn — Lesson 3: The Speed of Light
    struct LightSpeed {
        static let entry = "The speed of light is not just a speed limit. It is woven into the structure of matter itself."
        
        static func slider(at multiplier: Double) -> String {
            if multiplier < 0.2 {
                return "Chemistry breaks down. The periodic table rearranges. Life as we know it becomes impossible."
            } else if multiplier < 0.6 {
                return "A slower speed of light changes atomic bonding. Atoms larger. Matter less dense."
            } else if multiplier < 1.5 {
                return "Our universe. Calibrated over 13.8 billion years of consequence."
            } else {
                return "Faster light means tighter atoms, higher energy states. Stars burn differently. Perhaps faster."
            }
        }
        
        static let summary = "The speed of light determines the size of atoms, the colour of gold, the stability of matter. Change it — and you change everything."
    }
    
    // MARK: - Build — Constants Sliders
    struct Build {
        static let entry = "Our universe scores 94. Let's see how close you can get."
        
        static func gravityCard(for range: String) -> String {
            switch range {
            case "0.1–0.3x": return "Gravity too weak. Planets cannot form from dust clouds. Stars scatter."
            case "0.5–0.8x": return "Lower gravity. Planets form but are larger, less dense. Atmospheres escape easily."
            case "1.0x": return "Our gravity. The Goldilocks value — at least for carbon-based life."
            case "1.5–2.5x": return "Stronger gravity. Planets smaller and denser. Mountains cannot grow tall."
            case "3x–5x": return "Gravity dominates. Stars burn faster. Planetary surfaces are hostile."
            default: return "Crushing gravity. Matter compresses. Stars collapse faster. The universe darkens quickly."
            }
        }
        
        static func lightSpeedCard(for range: String) -> String {
            switch range {
            case "10% c": return "Atomic structure collapses. No stable chemistry. No molecules. No life."
            case "50% c": return "Matter exists but behaves strangely. Nuclear reactions fundamentally altered."
            case "1x c": return "Our universe. Calibrated over 13.8 billion years of consequence."
            case "2x c": return "Faster light means more energetic photons. Stars blaze hotter. Life windows narrow."
            default: return "Physics diverges completely. Speculative territory — even for physicists."
            }
        }
        
        static func planetMassCard(for range: String) -> String {
            switch range {
            case "0.1x Earth": return "Too light. Atmosphere bleeds away. No magnetic field. Radiation bombardment."
            case "0.5x Earth": return "Mars-like. Thin atmosphere. Limited protection. Life conceivable but difficult."
            case "1x Earth": return "Our mass. Atmosphere, plate tectonics, a magnetic shield. Sufficient."
            case "2x Earth": return "Super-Earth. Heavier atmosphere, stronger gravity. Life possible but different."
            default: return "Mini-Neptune territory. No solid surface accessible. Life as we know it: no."
            }
        }
        
        // MARK: - Verdicts
        static let stable = "Structure holds. Given time, complexity may emerge here."
        static let marginal = "Fragile equilibrium. This universe survives — barely."
        static let unstable = "The orbits decay within millions of years. No time for life."
        static let collapse = "This universe collapses. Nothing endures here."
        
        // MARK: - Score Comparison
        static func scoreComparison(score: Int) -> String {
            if score >= 85 {
                return "Close. The universe took 13.8 billion years to get here. You took three minutes."
            } else if score >= 70 {
                return "Respectable. Life might find a way — but it would be harder than ours."
            } else if score >= 50 {
                return "Marginal. Simpler organisms, perhaps. Nothing that builds or wonders."
            } else {
                return "94 points separate your universe from ours. Each one matters."
            }
        }
        
        // MARK: - Lesson Callbacks
        static let callbackStarTooHot = "Your star burns too hot — and too briefly. You learned why in Lesson 3."
        static let callbackInnerPlanetsTooMassive = "Your inner planets are too massive. Orbital mechanics cannot hold them. Lesson 2."
        static let callbackConstantsUnstable = "These constants do not permit stable atoms. Nothing complex can form. Lesson 3."
    }
    
    // MARK: - Challenge — Dead Universe
    struct DeadUniverse {
        struct Mystery1 {
            static let clue1 = "The stars burned bright — and briefly. Most collapsed within a billion years."
            static let clue2 = "Planets formed close to their stars. Their surfaces were crushed flat."
            static let clue3 = "No moon-sized bodies remain. Tidal forces tore them apart."
            static let answer = "Gravity too strong"
            static let postAnswer = "Strong gravity accelerates stellar evolution. Stars exhaust their fuel fast. No time for complexity."
        }
        
        struct Mystery2 {
            static let clue1 = "Atoms in this universe are large — bloated, unstable."
            static let clue2 = "No solid surfaces formed. Matter could not compress into rock."
            static let clue3 = "Chemistry here produced only the simplest elements. Nothing complex."
            static let answer = "Speed of light too low"
            static let postAnswer = "A slower light changes the fine-structure constant. Atoms lose stability. Chemistry loses range."
        }
        
        struct Mystery3 {
            static let clue1 = "The inner planets bear the scars of constant impact. Craters cover everything."
            static let clue2 = "No large body orbits far from the star. The outer system is empty."
            static let clue3 = "Comets arrive frequently. The inner system is bombarded without pause."
            static let answer = "No outer gas giant"
            static let postAnswer = "Jupiter intercepts debris that would otherwise devastate inner planets. Remove it — and the inner system never stabilises."
        }
    }
    
    // MARK: - Challenge — Rapid Fire
    struct RapidFire {
        struct Round1 {
            static let gravity = "0.1x"
            static let light = "1x"
            static let mass = "1x Earth"
            static let answer = "Life Impossible"
            static let explanation = "Gravity too weak. Atmospheres escape. Oceans evaporate. Life has no foundation."
        }
        
        struct Round2 {
            static let gravity = "1x"
            static let light = "0.5x"
            static let mass = "2x Earth"
            static let answer = "Life Impossible"
            static let explanation = "Light speed at half value destabilises atomic chemistry. The building blocks don't hold."
        }
        
        struct Round3 {
            static let gravity = "1.2x"
            static let light = "1x"
            static let mass = "1.5x Earth"
            static let answer = "Life Possible"
            static let explanation = "Slightly stronger gravity. Denser planets. Thicker atmospheres. Harder — but not impossible."
        }
        
        static func finalScore(_ score: Int) -> String {
            switch score {
            case 3: return "You understand what the universe requires. That understanding is rare."
            case 2: return "Close. The edge cases are where intuition fails. Physics does not."
            case 1: return "The constants are subtler than they appear. Return to the lessons."
            default: return "Start again. The universe does not negotiate."
            }
        }
    }
    
    // MARK: - Witness — Galaxy Collision
    struct Witness {
        static let approach = "Two galaxies, each containing hundreds of billions of stars. They have been falling toward each other for billions of years."
        static let firstPass = "They pass through each other. Stars almost never collide — the distances are too vast. But gravity distorts everything."
        static let tidalArms = "Long streams of stars are pulled out by tidal forces. Bridges of light between two dying structures."
        static let secondApproach = "Gravity will not let them escape. They fall back toward each other. This is inevitable."
        static let mergerBegins = "They are becoming one. New stars ignite from the compressed gas. The violence creates."
        static let finalState = "A single elliptical galaxy remains. Quieter now. Most star formation complete. A new structure — born from collision."
    }
}
