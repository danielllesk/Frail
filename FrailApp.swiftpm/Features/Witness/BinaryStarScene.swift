import SwiftUI
import SceneKit

struct BinaryStarScene: UIViewRepresentable {
    let progress: Double
    let isSupernova: Bool
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = .clear 
        scnView.allowsCameraControl = false
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = false
        
        let scene = SCNScene()
        scnView.scene = scene
        
        let cameraAnchor = SCNNode()
        cameraAnchor.name = "cameraAnchor"
        scene.rootNode.addChildNode(cameraAnchor)
        
        let cameraNode = SCNNode()
        cameraNode.name = "mainCamera"
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = 5000
        cameraNode.camera?.zNear = 0.1
        cameraAnchor.addChildNode(cameraNode)
        
        // Initial Camera Position
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 25)
        cameraNode.eulerAngles.x = -.pi/12
        
        let mainLight = SCNNode()
        mainLight.light = SCNLight()
        mainLight.light?.type = .omni
        mainLight.light?.intensity = 1000
        mainLight.position = SCNVector3(0, 10, 20)
        scene.rootNode.addChildNode(mainLight)
        
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 150
        ambientLight.light?.color = UIColor(white: 0.1, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLight)
        
        let starA = createStar(radius: 0.6, texture: "star_surface", color: UIColor(red: 0.85, green: 0.90, blue: 1.0, alpha: 1.0))
        starA.name = "starA"
        scene.rootNode.addChildNode(starA)
        
        let starB = createStar(radius: 2.0, texture: "star_surface", color: UIColor(red: 1.0, green: 0.35, blue: 0.1, alpha: 1.0))
        starB.name = "starB"
        scene.rootNode.addChildNode(starB)
        
        let selectionGlow = createSelectionGlow()
        selectionGlow.name = "selectionGlow"
        scene.rootNode.addChildNode(selectionGlow)
        
        let disc = createAccretionDisc()
        disc.name = "accretionDisc"
        disc.isHidden = true
        starA.addChildNode(disc)
        
        let streamNode = SCNNode()
        streamNode.name = "streamNode"
        scene.rootNode.addChildNode(streamNode)
        
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        guard let scene = scnView.scene else { return }
        guard let starA = scene.rootNode.childNode(withName: "starA", recursively: false),
              let starB = scene.rootNode.childNode(withName: "starB", recursively: false),
              let cameraNode = scene.rootNode.childNode(withName: "cameraAnchor", recursively: true)?.childNode(withName: "mainCamera", recursively: false),
              let selectionGlow = scene.rootNode.childNode(withName: "selectionGlow", recursively: false) else { return }
        
        let t = Float(progress)
        
        if isSupernova {
            // IMMEDIATE CLEANUP
            starA.isHidden = true
            starB.isHidden = true
            selectionGlow.isHidden = true
            
            // ANIMATED PULLBACK
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 4.0
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 120)
            cameraNode.eulerAngles.x = 0
            
            if let stream = scene.rootNode.childNode(withName: "streamNode", recursively: false) {
                stream.removeAllParticleSystems()
                stream.childNodes.forEach { $0.removeAllParticleSystems() }
            }
            SCNTransaction.commit()
        } else {
            starA.isHidden = false
            starB.isHidden = false
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            cameraNode.position = SCNVector3(x: 0, y: 5, z: 25)
            cameraNode.eulerAngles.x = -.pi/12
            SCNTransaction.commit()
            
            let startDist: Float = 12.0
            starA.position.x = -startDist * (1.0 - t)
            starB.position.x = startDist * (1.0 - t)
            
            let distortion = 1.0 + (t > 0.4 ? (t - 0.4) * 0.5 : 0)
            starB.scale = SCNVector3(distortion, 1.0, 1.0)
            
            if t > 0.3 {
                updateTidalStream(in: scene, from: starB, to: starA, progress: t)
            } else {
                scene.rootNode.childNode(withName: "streamNode", recursively: false)?.removeAllParticleSystems()
            }
            
            if let disc = starA.childNode(withName: "accretionDisc", recursively: true) {
                disc.isHidden = t < 0.4
                disc.opacity = CGFloat(max(0, (t - 0.4) * 1.5))
            }
        }
    }
    
    private func createStar(radius: CGFloat, texture: String, color: UIColor) -> SCNNode {
        let sphere = SCNSphere(radius: radius)
        sphere.segmentCount = 64
        let mat = SCNMaterial()
        if let img = UIImage(named: texture) {
            mat.diffuse.contents = img
            mat.emission.contents = img
        } else {
            mat.diffuse.contents = color
            mat.emission.contents = color
        }
        mat.emission.intensity = (radius < 1.0) ? 1.2 : 0.8
        sphere.materials = [mat]
        
        let node = SCNNode(geometry: sphere)
        let rotate = CABasicAnimation(keyPath: "rotation")
        rotate.fromValue = NSValue(scnVector4: SCNVector4(0, 1, 0, 0))
        rotate.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
        rotate.duration = (radius < 1.0) ? 10 : 30
        rotate.repeatCount = .infinity
        node.addAnimation(rotate, forKey: "starRotation")
        return node
    }
    
    private func createSelectionGlow() -> SCNNode {
        let sphere = SCNSphere(radius: 2.2)
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor.white.withAlphaComponent(0.1)
        mat.emission.contents = UIColor.white
        mat.emission.intensity = 0.5
        mat.blendMode = .add
        sphere.materials = [mat]
        
        let node = SCNNode(geometry: sphere)
        node.isHidden = true
        return node
    }
    
    private func createAccretionDisc() -> SCNNode {
        let disc = SCNTorus(ringRadius: 1.8, pipeRadius: 0.1)
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor.orange.withAlphaComponent(0.5)
        mat.emission.contents = UIColor.orange
        mat.blendMode = .add
        disc.materials = [mat]
        let node = SCNNode(geometry: disc)
        node.scale.y = 0.05
        node.eulerAngles.x = .pi / 2
        return node
    }
    
    private func updateTidalStream(in scene: SCNScene, from donor: SCNNode, to acceptor: SCNNode, progress: Float) {
        guard let container = scene.rootNode.childNode(withName: "streamNode", recursively: false) else { return }
        
        if progress > 0.95 || isSupernova {
            container.removeAllParticleSystems()
            container.childNodes.forEach { $0.removeAllParticleSystems() }
            return
        }
        
        let emitterName = "tidalEmitter"
        var emitterNode = container.childNode(withName: emitterName, recursively: false)
        
        if emitterNode == nil {
            emitterNode = SCNNode()
            emitterNode?.name = emitterName
            emitterNode?.eulerAngles.x = -.pi / 2
            container.addChildNode(emitterNode!)
        }
        
        if emitterNode?.particleSystems?.isEmpty ?? true {
            let stream = SCNParticleSystem()
            stream.emitterShape = SCNPlane(width: 0.05, height: 0.05)
            stream.particleColor = UIColor(red: 1.0, green: 0.8, blue: 0.5, alpha: 0.9)
            stream.particleSize = 0.1
            stream.birthRate = 1200
            stream.particleLifeSpan = 0.5
            stream.particleVelocity = 14.0
            stream.particleVelocityVariation = 0
            stream.spreadingAngle = 0
            stream.blendMode = .additive
            emitterNode?.addParticleSystem(stream)
        }
        
        container.position = donor.position
        container.look(at: acceptor.position)
        
        if let system = emitterNode?.particleSystems?.first {
            system.birthRate = CGFloat(600 + progress * 1000)
            let rawDist = simd_distance(donor.simdPosition, acceptor.simdPosition)
            let surfaceDist = max(0.1, rawDist - 0.6) 
            let velocity: CGFloat = 14.0
            system.particleVelocity = velocity
            system.particleLifeSpan = CGFloat(surfaceDist) / velocity
        }
    }
}
