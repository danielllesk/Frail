//
//  TypewriterText.swift
//  Frail
//
//  Shared component for typewriter text animation.
//

import SwiftUI

struct TypewriterText: View {
    let text: String
    var speed: Double = 0.02
    @State private var displayedText: String = ""
    @State private var task: Task<Void, Never>?
    
    var body: some View {
        Text(displayedText)
            .onAppear {
                startTyping()
            }
            .onChange(of: text) { _ in
                startTyping()
            }
            .onDisappear {
                task?.cancel()
            }
    }
    
    private func startTyping() {
        task?.cancel()
        task = Task { @MainActor in
            displayedText = ""
            for char in text {
                if Task.isCancelled { break }
                displayedText.append(char)
                try? await Task.sleep(nanoseconds: UInt64(speed * 1_000_000_000))
            }
        }
    }
}
