//
//  LearnContainerView.swift
//  Frail
//
//  Lesson progression — Chapter 1 → 2 → 3, with back navigation.
//

import SwiftUI

enum Lesson: Int, CaseIterable, Identifiable {
    case gravity = 1
    case lightSpeed = 2
    case time = 3
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .gravity: return "Gravity"
        case .lightSpeed: return "Light"
        case .time: return "Time"
        }
    }
    
    var chapter: String {
        "Chapter \(rawValue)"
    }
}

struct LearnContainerView: View {
    let onComplete: () -> Void
    
    @State private var currentLesson: Lesson = .gravity
    @State private var completedLessons: Set<Lesson> = []
    
    var body: some View {
        ZStack {
            Color.frailBackground
                .ignoresSafeArea()
            
            StarFieldView()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ── Header: back button + progress dots ──
                HStack {
                    // Back button
                    Button(action: goBack) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text(backLabel)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.frailMutedText)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    // Progress dots
                    HStack(spacing: 8) {
                        ForEach(Lesson.allCases) { lesson in
                            Circle()
                                .fill(dotColor(for: lesson))
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Spacer()
                    
                    // Skip button
                    Button(action: skipLesson) {
                        Text(currentLesson == .time ? "Close" : "Skip")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.frailGold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.frailGold.opacity(0.1))
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // ── Lesson content ──
                Group {
                    switch currentLesson {
                    case .gravity:
                        GravityView(
                            onComplete: { completeLesson(.gravity) }
                        )
                    case .lightSpeed:
                        LightSpeedView(
                            onComplete: { completeLesson(.lightSpeed) }
                        )
                    case .time:
                        TimeDilationView(
                            onComplete: { completeLesson(.time) }
                        )
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: currentLesson)
    }
    
    // MARK: - Navigation
    
    private var backLabel: String {
        if currentLesson == .gravity {
            return "Home"
        } else if let prev = Lesson(rawValue: currentLesson.rawValue - 1) {
            return prev.title
        }
        return "Back"
    }
    
    private func goBack() {
        if currentLesson == .gravity {
            // First lesson → go home
            onComplete()
        } else if let prev = Lesson(rawValue: currentLesson.rawValue - 1) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                currentLesson = prev
            }
        }
    }
    
    private func dotColor(for lesson: Lesson) -> Color {
        if completedLessons.contains(lesson) {
            return .frailEmerald
        } else if lesson == currentLesson {
            return .frailGold
        } else {
            return .frailMutedText.opacity(0.3)
        }
    }
    
    private func skipLesson() {
        if let nextLesson = Lesson(rawValue: currentLesson.rawValue + 1) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                currentLesson = nextLesson
            }
        } else {
            // Last lesson -> home
            onComplete()
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
