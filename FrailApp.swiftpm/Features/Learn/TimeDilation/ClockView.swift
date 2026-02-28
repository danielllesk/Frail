//
//  ClockView.swift
//  Frail
//
//  Premium Canvas-based clock visualization.
//

import SwiftUI

struct ClockView: View {
    let age: Double
    let label: String
    
    var body: some View {
        VStack(spacing: 24) {
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let radius = min(size.width, size.height) / 2 - 15
                
                // One rotation = 1 year. 
                // Using age directly for the angle. 
                // In standard clock coords: 0 is Up, so we subtract .pi/2 if needed, 
                // but for sin/cos where 0 is Right, we adjust.
                // For a hand: angle 0 = Up, increases clockwise.
                let angle = (age * 2 * .pi)
                
                // 1. Draw Clock Face (Outer Ring)
                var path = Path()
                path.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
                context.stroke(path, with: .color(.frailMutedText.opacity(0.3)), lineWidth: 3)
                
                // 2. Draw Hour Markers
                for i in 0..<12 {
                    // Offset by -.pi/2 so i=0 is at the top (12 o'clock)
                    let markerAngle = Double(i) * (.pi / 6) - (.pi / 2)
                    let start = CGPoint(
                        x: center.x + (radius - 12) * CGFloat(cos(markerAngle)),
                        y: center.y + (radius - 12) * CGFloat(sin(markerAngle))
                    )
                    let end = CGPoint(
                        x: center.x + radius * CGFloat(cos(markerAngle)),
                        y: center.y + radius * CGFloat(sin(markerAngle))
                    )
                    
                    var markerPath = Path()
                    markerPath.move(to: start)
                    markerPath.addLine(to: end)
                    context.stroke(markerPath, with: .color(.frailMutedText.opacity(0.5)), lineWidth: 3)
                }
                
                // 3. Draw Hand
                let handLength = radius - 8
                // Hand points Up at angle 0
                let handEnd = CGPoint(
                    x: center.x + handLength * CGFloat(sin(angle)),
                    y: center.y - handLength * CGFloat(cos(angle))
                )
                
                var handPath = Path()
                handPath.move(to: center)
                handPath.addLine(to: handEnd)
                context.stroke(handPath, with: .color(.frailAccent), lineWidth: 4)
                
                // Center pin
                let pinR: CGFloat = 6
                let pinRect = CGRect(x: center.x - pinR, y: center.y - pinR, width: pinR * 2, height: pinR * 2)
                context.fill(Circle().path(in: pinRect), with: .color(.frailAccent))
                
                // Glow for hand
                context.addFilter(.blur(radius: 6))
                context.stroke(handPath, with: .color(.frailAccent.opacity(0.5)), lineWidth: 8)
            }
            .frame(width: 240, height: 240)
            
            VStack(spacing: 6) {
                Text(label)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.frailPrimaryText)
                    .tracking(2)
                
                Text(String(format: "Age: %.1f years", age))
                    .font(.system(size: 22, weight: .semibold, design: .monospaced))
                    .foregroundColor(.frailGold)
            }
        }
    }
}
