//
//  LearnContainerView.swift
//  Frail
//
//  Lesson progression, progress dots, transitions
//

import SwiftUI

enum Lesson: Int, CaseIterable, Identifiable {
    case timeDilation = 1
    case gravity = 2
    case lightSpeed = 3
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .timeDilation: return "Time"
        case .gravity: return "Gravity"
        case .lightSpeed: return "Light Speed"
        }
    }
}

struct LearnContainerView: View {
    let onComplete: () -> Void
    
    @State private var currentLesson: Lesson = .timeDilation
    @State private var completedLessons: Set<Lesson> = []
    
    var body: some View {
        ZStack {
            Color.frailBackground
                .ignoresSafeArea()
            
            StarFieldView()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(Lesson.allCases) { lesson in
                        Circle()
                            .fill(lessonState(for: lesson))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 16)
                
                // Lesson content
                Group {
                    switch currentLesson {
                    case .timeDilation:
                        TimeDilationView(
                            onComplete: { completeLesson(.timeDilation) }
                        )
                    case .gravity:
                        GravityView(
                            onComplete: { completeLesson(.gravity) }
                        )
                    case .lightSpeed:
                        LightSpeedView(
                            onComplete: { completeLesson(.lightSpeed) }
                        )
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
    }
    
    private func lessonState(for lesson: Lesson) -> Color {
        if completedLessons.contains(lesson) {
            return .frailEmerald
        } else if lesson == currentLesson {
            return .frailGold
        } else {
            return .frailMutedText.opacity(0.3)
        }
    }
    
    private func completeLesson(_ lesson: Lesson) {
        completedLessons.insert(lesson)
        HapticEngine.shared.playLessonComplete()
        
        if let nextLesson = Lesson(rawValue: lesson.rawValue + 1) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                currentLesson = nextLesson
            }
        } else {
            // All lessons complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                onComplete()
            }
        }
    }
}
