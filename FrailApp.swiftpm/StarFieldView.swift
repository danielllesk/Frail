import SwiftUI
@preconcurrency import CoreMotion
import Combine

struct StarFieldView: View {
    @StateObject private var motion = MotionManager()
    @State private var stars: [Star] = []
    @State private var shootingStars: [ShootingStar] = []
    @State private var shootingStarTimer: Timer?
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                // Static stars
                for star in stars {
                    let offsetX = motion.roll * star.parallax * 20
                    let offsetY = motion.pitch * star.parallax * 20
                    
                    // Subtle twinkle based on time
                    let time = timeline.date.timeIntervalSinceReferenceDate
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
                for shootingStar in shootingStars {
                    let elapsed = now - shootingStar.startTime
                    let progress = elapsed / shootingStar.duration
                    
                    guard progress >= 0 && progress <= 1 else { continue }
                    
                    let currentX = shootingStar.startX + (shootingStar.endX - shootingStar.startX) * progress
                    let currentY = shootingStar.startY + (shootingStar.endY - shootingStar.startY) * progress
                    
                    // Fade in then out
                    let alpha = progress < 0.3
                        ? progress / 0.3
                        : (1.0 - progress) / 0.7
                    
                    // Draw tail
                    let tailLength: Double = 40
                    let dx = shootingStar.endX - shootingStar.startX
                    let dy = shootingStar.endY - shootingStar.startY
                    let dist = sqrt(dx * dx + dy * dy)
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
                    
                    // Bright head
                    let headRect = CGRect(x: headX - 1.5, y: headY - 1.5, width: 3, height: 3)
                    context.fill(
                        Path(ellipseIn: headRect),
                        with: .color(.white.opacity(alpha * 0.9))
                    )
                }
            }
        }
        .onAppear {
            generateStars()
            startShootingStars()
        }
        .onDisappear {
            shootingStarTimer?.invalidate()
            shootingStarTimer = nil
        }
    }
    
    private func generateStars(count: Int = 500) {
        stars = (0..<count).map { _ in
            Star(
                position: CGPoint(x: .random(in: -0.02...1.02), y: .random(in: -0.02...1.02)),
                size: CGFloat.random(in: 1.5...3.5),
                opacity: Double.random(in: 0.5...1.0),
                parallax: Double.random(in: 0.2...1.0),
                twinkleSpeed: Double.random(in: 1.0...4.0),
                twinkleOffset: Double.random(in: 0...6.28)
            )
        }
    }
    
    private func startShootingStars() {
        spawnShootingStar()
        
        shootingStarTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            Task { @MainActor in
                // Random chance — not every interval produces a shooting star
                if Double.random(in: 0...1) < 0.7 {
                    spawnShootingStar()
                }
            }
        }
    }
    
    private func spawnShootingStar() {
        let star = ShootingStar(
            startX: Double.random(in: 0.1...0.9),
            startY: Double.random(in: 0.05...0.4),
            endX: Double.random(in: 0.2...1.0),
            endY: Double.random(in: 0.15...0.5),
            duration: Double.random(in: 0.6...1.2),
            startTime: Date().timeIntervalSinceReferenceDate
        )
        shootingStars.append(star)
        
        // Clean up old shooting stars
        let now = Date().timeIntervalSinceReferenceDate
        shootingStars.removeAll { now - $0.startTime > $0.duration + 1 }
    }
    
    struct Star {
        var position: CGPoint
        var size: CGFloat
        var opacity: Double
        var parallax: Double
        var twinkleSpeed: Double
        var twinkleOffset: Double
    }
    
    struct ShootingStar {
        var startX: Double
        var startY: Double
        var endX: Double
        var endY: Double
        var duration: Double
        var startTime: TimeInterval
    }
}

@MainActor
final class MotionManager: ObservableObject {
    @Published var pitch: Double = 0
    @Published var roll: Double = 0
    
    private let manager = CMMotionManager()
    
    init() {
        manager.deviceMotionUpdateInterval = 1.0 / 60.0
        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let motion = motion else { return }
            self?.pitch = motion.attitude.pitch
            self?.roll = motion.attitude.roll
        }
    }
    
    deinit {
        manager.stopDeviceMotionUpdates()
    }
}
