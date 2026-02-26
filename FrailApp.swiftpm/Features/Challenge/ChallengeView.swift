//
//  ChallengeView.swift
//  Frail
//
//  Challenge section - placeholder
//

import SwiftUI

struct ChallengeView: View {
    let onBack: () -> Void
    
    var body: some View {
        VStack {
            Text("Challenge")
                .font(.system(size: 32, weight: .medium, design: .rounded))
                .foregroundColor(Color.frailPrimaryText)
            
            Text("Dead Universe & Rapid Fire coming soon")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(Color.frailMutedText)
                .padding()
            
            Button(action: onBack) {
                Text("Back")
                    .foregroundColor(Color.frailAccent)
            }
        }
    }
}
