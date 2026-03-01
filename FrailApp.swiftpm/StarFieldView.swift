import SwiftUI

struct StarFieldView: View {
    @ObservedObject var controller: StarFieldController = .shared
    
    var body: some View {
        if controller.isVisible {
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    
                    // Static stars
                    for star in controller.stars {
                        let offsetX = controller.roll * star.parallax * 20
                        let offsetY = controller.pitch * star.parallax * 20
                        
                        // Subtle twinkle based on time
                        let twinkle = 0.8 + 0.2 * sin(time * star.twinkleSpeed + star.twinkleOffset)
                        
                        let rect = CGRect(
                            x: star.position.x * size.width + offsetX,
                            y: star.position.y * size.height + offsetY,
                            width: star.size,
                            height: star.size
                        )
                        
                        context.fill(
                            Path(ellipseIn: rect),
                            with: .color(.white.opacity(star.opacity * twinkle))
                        )
                    }
                    
                    // Shooting stars
                    let now = timeline.date.timeIntervalSinceReferenceDate
                    for shootingStar in controller.shootingStars {
                        let elapsed = now - shootingStar.startTime
                        let progress = elapsed / shootingStar.duration
                        
                        guard progress >= 0 && progress <= 1.0 else { continue }
                        
                        let currentX = shootingStar.startX + (shootingStar.endX - shootingStar.startX) * progress
                        let currentY = shootingStar.startY + (shootingStar.endY - shootingStar.startY) * progress
                        
                        // Fade in then out
                        let alpha = progress < 0.3
                            ? progress / 0.3
                            : (1.0 - progress) / 0.7
                        
                        let tailLength: Double = 40
                        let dx = shootingStar.endX - shootingStar.startX
                        let dy = shootingStar.endY - shootingStar.startY
                        let dist = sqrt(dx * dx + dy * dy)
                        
                        guard dist > 0.001 else { continue }
                        
                        let nx = dx / dist * tailLength
                        let ny = dy / dist * tailLength
                        
                        let headX = currentX * size.width
                        let headY = currentY * size.height
                        let tailX = headX - nx
                        let tailY = headY - ny
                        
                        var path = Path()
                        path.move(to: CGPoint(x: tailX, y: tailY))
                        path.addLine(to: CGPoint(x: headX, y: headY))
                        
                        context.stroke(
                            path,
                            with: .linearGradient(
                                Gradient(colors: [
                                    .white.opacity(0),
                                    .white.opacity(alpha * 0.8)
                                ]),
                                startPoint: CGPoint(x: tailX, y: tailY),
                                endPoint: CGPoint(x: headX, y: headY)
                            ),
                            lineWidth: 1.5
                        )
                        
                        let headRect = CGRect(x: headX - 1.5, y: headY - 1.5, width: 3, height: 3)
                        context.fill(
                            Path(ellipseIn: headRect),
                            with: .color(.white.opacity(alpha * 0.9))
                        )
                    }
                    
                    // Cleanup is now handled by the controller during spawning
                }
            }
            .drawingGroup() // Metal-backed performance
        }
    }
}
