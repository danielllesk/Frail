//
//  BinaryStarScene.swift
//  Frail
//
//  SceneKit binary star system collision.
//  Two stars: A (White Dwarf) and B (Younger Star).
//

import SwiftUI
import SceneKit

struct BinaryStarScene: UIViewRepresentable {
    /// Progress of the approach/collision (0.0 to 1.0)
    let progress: Double
    /// Whether the supernova has been triggered
    let isSupernova: Bool
    /// Which star to frame/highlight
    let highlightedStar: String?
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = .clear // Allow SwiftUI starfield to show through
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = false
        
        let scene = SCNScene()
        
        // 1. Camera setup
        let cameraAnchor = SCNNode()
        cameraAnchor.name = "cameraAnchor"
        scene.rootNode.addChildNode(cameraAnchor)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = 5000
        cameraNode.camera?.zNear = 0.1
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 25)
        cameraNode.eulerAngles = SCNVector3(x: -.pi/12, y: 0, z: 0)
        cameraAnchor.addChildNode(cameraNode)
        
        // 2. Lighting
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
        
        // 3. Stars
        let starA = createStar(radius: 0.8, texture: "star_surface", color: .orange)
        starA.name = "starA"
        scene.rootNode.addChildNode(starA)
        
        let starB = createStar(radius: 1.4, texture: "star_surface", color: UIColor(red: 0.7, green: 0.9, blue: 1.0, alpha: 1.0))
        starB.name = "starB"
        scene.rootNode.addChildNode(starB)
        
        // 4. Selection Glow (HIDDEN initially)
        let selectionGlow = createSelectionGlow()
        selectionGlow.name = "selectionGlow"
        selectionGlow.isHidden = true
        scene.rootNode.addChildNode(selectionGlow)
        
        // 5. Accretion Disc (HIDDEN initially)
        let disc = createAccretionDisc()
        disc.name = "accretionDisc"
        disc.isHidden = true
        starA.addChildNode(disc)
        
        // 6. Tidal Stream
        let streamNode = SCNNode()
        streamNode.name = "streamNode"
        scene.rootNode.addChildNode(streamNode)
        
        // 7. CINEMATIC ASSETS (HIDDEN initially)
        let nebula = create3DNebula()
        nebula.name = "nebulaNode"
        nebula.isHidden = true
        scene.rootNode.addChildNode(nebula)
        
        let ring = create3DRing()
        ring.name = "ringNode"
        ring.isHidden = true
        scene.rootNode.addChildNode(ring)
        
        scnView.scene = scene
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        guard let scene = scnView.scene else { return }
        guard let starA = scene.rootNode.childNode(withName: "starA", recursively: false),
              let starB = scene.rootNode.childNode(withName: "starB", recursively: false),
              let nebula = scene.rootNode.childNode(withName: "nebulaNode", recursively: false),
              let ring = scene.rootNode.childNode(withName: "ringNode", recursively: false),
              let cameraNode = scene.rootNode.childNode(withName: "cameraAnchor", recursively: true)?.childNodes.first,
              let selectionGlow = scene.rootNode.childNode(withName: "selectionGlow", recursively: false) else { return }
        
        let t = Float(progress)
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = isSupernova ? 3.0 : 0.8
        
        if isSupernova {
            starA.isHidden = true
            starB.isHidden = true
            selectionGlow.isHidden = true
            
            nebula.isHidden = false
            nebula.opacity = 1.0
            nebula.scale = SCNVector3(3.0, 3.0, 3.0) // Reduced from 4.0 to feel less "zoomed in"
            
            ring.isHidden = false
            ring.opacity = 0.8
            ring.scale = SCNVector3(30, 30, 30)
            
            cameraNode.position = SCNVector3(0, 8, 85) // Pulled back from 55 to 85 for grander scale
        } else {
            starA.isHidden = false
            starB.isHidden = false
            starA.opacity = 1.0
            starB.opacity = 1.0
            
            nebula.isHidden = true
            ring.isHidden = true
            
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
            
            if let targetName = highlightedStar,
               let targetNode = scene.rootNode.childNode(withName: targetName, recursively: false) {
                selectionGlow.isHidden = false
                selectionGlow.position = targetNode.position
                selectionGlow.scale = SCNVector3(targetNode.scale.x * 1.5, 1.5, 1.5)
                cameraNode.position = SCNVector3(targetNode.position.x, 2, 8)
            } else {
                selectionGlow.isHidden = true
                cameraNode.position = SCNVector3(0, 5, 25)
            }
            
            if let disc = starA.childNode(withName: "accretionDisc", recursively: true) {
                disc.isHidden = t < 0.4
                disc.opacity = CGFloat(max(0, (t - 0.4) * 1.5))
            }
        }
        
        SCNTransaction.commit()
    }
    
    // MARK: - Node Creation Helpers
    
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
        mat.emission.intensity = 0.8
        mat.multiply.contents = color
        sphere.materials = [mat]
        
        let node = SCNNode(geometry: sphere)
        let rotate = CABasicAnimation(keyPath: "rotation")
        rotate.fromValue = NSValue(scnVector4: SCNVector4(0, 1, 0, 0))
        rotate.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
        rotate.duration = 15
        rotate.repeatCount = .infinity
        node.addAnimation(rotate, forKey: "starRotation")
        return node
    }
    
    private func create3DNebula() -> SCNNode {
        let sphere = SCNSphere(radius: 20.0)
        sphere.segmentCount = 64
        let mat = SCNMaterial()
        if let img = UIImage(named: "crab_nebula") {
            mat.diffuse.contents = img
            mat.emission.contents = img
        } else {
            mat.diffuse.contents = UIColor.black
        }
        mat.emission.intensity = 0.7 
        mat.isDoubleSided = true
        mat.blendMode = SCNBlendMode.screen
        
        // FRESNEL EFFECT for soft edges
        mat.fresnelExponent = 2.0
        
        sphere.materials = [mat]
        
        let node = SCNNode(geometry: sphere)
        node.scale = SCNVector3(0.1, 0.1, 0.1)
        
        let rotate = CABasicAnimation(keyPath: "rotation")
        rotate.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0.2, Float.pi * 2))
        rotate.duration = 120
        rotate.repeatCount = .infinity
        node.addAnimation(rotate, forKey: "nebulaSpin")
        return node
    }
    
    private func create3DRing() -> SCNNode {
        let torus = SCNTorus(ringRadius: 10.0, pipeRadius: 0.2)
        let mat = SCNMaterial()
        if let img = UIImage(named: "supernova_ring") {
            mat.diffuse.contents = img
            mat.emission.contents = img
        } else {
            mat.diffuse.contents = UIColor.orange
        }
        mat.emission.intensity = 2.0
        mat.blendMode = SCNBlendMode.add
        torus.materials = [mat]
        
        let node = SCNNode(geometry: torus)
        node.eulerAngles.x = .pi / 2
        node.scale = SCNVector3(0.1, 0.1, 0.1)
        return node
    }
    
    private func createSelectionGlow() -> SCNNode {
        let sphere = SCNSphere(radius: 1.6)
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor.clear
        mat.emission.contents = UIColor(white: 0.3, alpha: 1.0)
        mat.blendMode = SCNBlendMode.add
        sphere.materials = [mat]
        return SCNNode(geometry: sphere)
    }
    
    private func createAccretionDisc() -> SCNNode {
        let disc = SCNTorus(ringRadius: 1.8, pipeRadius: 0.1)
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor.orange.withAlphaComponent(0.5)
        mat.emission.contents = UIColor.orange
        mat.blendMode = SCNBlendMode.add
        disc.materials = [mat]
        let node = SCNNode(geometry: disc)
        node.scale.y = 0.05
        node.eulerAngles.x = .pi / 2
        return node
    }
    
    private func updateTidalStream(in scene: SCNScene, from donor: SCNNode, to acceptor: SCNNode, progress: Float) {
        guard let container = scene.rootNode.childNode(withName: "streamNode", recursively: false) else { return }
        if container.particleSystems?.isEmpty ?? true {
            let stream = SCNParticleSystem()
            stream.emitterShape = SCNSphere(radius: 0.2)
            stream.particleColor = UIColor(red: 1.0, green: 0.7, blue: 0.4, alpha: 0.6)
            stream.particleSize = 0.04
            stream.birthRate = 600
            stream.particleLifeSpan = 0.6
            stream.particleVelocity = 6.0
            stream.emissionDirection = SCNVector3(0, 0, -1) // ALIGN WITH SCENEOBJECT LOOK-AT (NEGATIVE Z)
            stream.blendMode = SCNParticleBlendMode.additive
            container.addParticleSystem(stream)
        }
        container.position = donor.position
        container.look(at: acceptor.position)
        if let system = container.particleSystems?.first {
            system.birthRate = CGFloat(400 + progress * 800)
        }
    }
}
