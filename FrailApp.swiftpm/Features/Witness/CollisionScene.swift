//
//  CollisionScene.swift
//  Frail
//
//  SceneKit galaxy collision simulation.
//

import SwiftUI
import SceneKit

struct CollisionScene: UIViewRepresentable {
    let progress: Double // 0.0 to 1.0
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = .clear
        scnView.antialiasingMode = .multisampling4X
        
        let scene = SCNScene()
        
        // Camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 20)
        cameraNode.eulerAngles = SCNVector3(x: -.pi/6, y: 0, z: 0)
        scene.rootNode.addChildNode(cameraNode)
        
        // Two Galaxy Groups
        let galaxy1 = createGalaxy(color: .systemBlue)
        galaxy1.name = "galaxy1"
        scene.rootNode.addChildNode(galaxy1)
        
        let galaxy2 = createGalaxy(color: .systemPink)
        galaxy2.name = "galaxy2"
        scene.rootNode.addChildNode(galaxy2)
        
        scnView.scene = scene
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        guard let scene = scnView.scene else { return }
        
        let g1 = scene.rootNode.childNode(withName: "galaxy1", recursively: false)
        let g2 = scene.rootNode.childNode(withName: "galaxy2", recursively: false)
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        
        // Phase 1: Approach (0 to 0.3)
        // Phase 2: Merger (0.3 to 0.7)
        // Phase 3: Final state (0.7 to 1.0)
        
        let t = Float(progress)
        
        // Galaxy 1 positioning
        let startX1: Float = -15.0
        let endX1: Float = 0.0
        g1?.position.x = startX1 + (endX1 - startX1) * t
        g1?.position.z = -5 * sin(t * .pi)
        
        // Galaxy 2 positioning
        let startX2: Float = 15.0
        let endX2: Float = 0.0
        g2?.position.x = startX2 + (endX2 - startX2) * t
        g2?.position.z = 5 * sin(t * .pi)
        
        // Scale and Opacity during merger
        let scale = 1.0 + sin(t * .pi) * 0.5
        g1?.scale = SCNVector3(scale, scale, scale)
        g2?.scale = SCNVector3(scale, scale, scale)
        
        SCNTransaction.commit()
    }
    
    private func createGalaxy(color: UIColor) -> SCNNode {
        let node = SCNNode()
        
        // Create a disc of particles (simplified for student challenge)
        for _ in 0..<200 {
            let star = SCNSphere(radius: 0.05)
            star.firstMaterial?.lightingModel = .constant
            star.firstMaterial?.diffuse.contents = color
            
            let starNode = SCNNode(geometry: star)
            let r = Float.random(in: 1.0...6.0)
            let angle = Float.random(in: 0...(.pi * 2))
            
            starNode.position = SCNVector3(
                r * cos(angle),
                Float.random(in: -0.2...0.2),
                r * sin(angle)
            )
            node.addChildNode(starNode)
        }
        
        // Add a central core glow
        let core = SCNSphere(radius: 0.8)
        core.firstMaterial?.lightingModel = .constant
        core.firstMaterial?.diffuse.contents = color
        let coreNode = SCNNode(geometry: core)
        coreNode.opacity = 0.5
        node.addChildNode(coreNode)
        
        return node
    }
}
