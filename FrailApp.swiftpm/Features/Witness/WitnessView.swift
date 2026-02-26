//
//  WitnessView.swift
//  Frail
//
//  Witness section - placeholder
//

import SwiftUI

struct WitnessView: View {
    let onBack: () -> Void
    
    var body: some View {
        VStack {
            Text("Witness")
                .font(.system(size: 32, weight: .medium, design: .rounded))
                .foregroundColor(Color.frailPrimaryText)
            
            Text("Galaxy collision coming soon")
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
