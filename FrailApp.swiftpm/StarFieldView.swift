import SwiftUI
@preconcurrency import CoreMotion
import Combine

struct StarFieldView: View {
    @StateObject private var motion = MotionManager()
    @State private var stars: [Star] = []
    
    var body: some View {
        Canvas { context, size in
            for star in stars {
                let offsetX = motion.roll * star.parallax * 20
                let offsetY = motion.pitch * star.parallax * 20
                
                let rect = CGRect(
                    x: star.position.x * size.width + offsetX,
                    y: star.position.y * size.height + offsetY,
                    width: star.size,
                    height: star.size
                )
                
                context.fill(
                    Path(ellipseIn: rect),
                    with: .color(.white.opacity(star.opacity))
                )
            }
        }
        .onAppear {
            generateStars()
        }
    }
    
    private func generateStars(count: Int = 320) {
        stars = (0..<count).map { _ in
            Star(
                position: CGPoint(x: .random(in: 0...1), y: .random(in: 0...1)),
                size: CGFloat.random(in: 1.0...2.3),
                opacity: Double.random(in: 0.4...1.0),
                parallax: Double.random(in: 0.2...1.0)
            )
        }
    }
    
    struct Star {
        var position: CGPoint
        var size: CGFloat
        var opacity: Double
        var parallax: Double
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
