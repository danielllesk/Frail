import SwiftUI
import CoreMotion

@MainActor
final class StarFieldController: ObservableObject {
    static let shared = StarFieldController()
    
    @Published var stars: [Star] = []
    @Published var shootingStars: [ShootingStar] = []
    @Published var isVisible: Bool = true
    
    // Parallax state
    @Published var pitch: Double = 0
    @Published var roll: Double = 0
    
    private let motionManager = CMMotionManager()
    private var shootingStarTimer: Timer?
    
    private init() {
        generateStars(count: 500)
        startMotionUpdates()
        startShootingStars()
    }
    
    private func generateStars(count: Int) {
        stars = (0..<count).map { _ in
            Star(
                position: CGPoint(x: .random(in: -0.05...1.05), y: .random(in: -0.05...1.05)),
                size: CGFloat.random(in: 1.5...3.5),
                opacity: Double.random(in: 0.4...0.9),
                parallax: Double.random(in: 0.2...1.2),
                twinkleSpeed: Double.random(in: 1.0...4.0),
                twinkleOffset: Double.random(in: 0...6.28)
            )
        }
    }
    
    private func startMotionUpdates() {
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let motion = motion else { return }
            self?.pitch = motion.attitude.pitch
            self?.roll = motion.attitude.roll
        }
    }
    
    private func startShootingStars() {
        shootingStarTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, self.isVisible else { return }
                if Double.random(in: 0...1) < 0.7 {
                    self.spawnShootingStar()
                }
            }
        }
    }
    
    private func spawnShootingStar() {
        let now = Date().timeIntervalSinceReferenceDate
        shootingStars.removeAll { now - $0.startTime > $0.duration + 0.5 }

        let star = ShootingStar(
            startX: Double.random(in: 0.1...0.9),
            startY: Double.random(in: 0.05...0.4),
            endX: Double.random(in: 0.2...1.0),
            endY: Double.random(in: 0.15...0.5),
            duration: Double.random(in: 0.6...1.5),
            startTime: now
        )
        shootingStars.append(star)
    }
    
    func cleanupShootingStars(now: TimeInterval) {
        shootingStars.removeAll { now - $0.startTime > $0.duration + 0.5 }
    }
    
    struct Star: Identifiable {
        let id = UUID()
        let position: CGPoint
        let size: CGFloat
        let opacity: Double
        let parallax: Double
        let twinkleSpeed: Double
        let twinkleOffset: Double
    }
    
    struct ShootingStar: Identifiable {
        let id = UUID()
        let startX: Double
        let startY: Double
        let endX: Double
        let endY: Double
        let duration: Double
        let startTime: TimeInterval
    }
}
