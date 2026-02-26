//
//  EarthSceneView.swift
//  Frail
//
//  SceneKit-based rotating Earth for the intro screen.
//

import SwiftUI
import SceneKit

// MARK: - SwiftUI wrapper

struct EarthSceneView: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = makeScene()
        sceneView.backgroundColor = .clear
        sceneView.allowsCameraControl = false
        sceneView.showsStatistics = false
        sceneView.isUserInteractionEnabled = false
        sceneView.autoenablesDefaultLighting = false
        sceneView.antialiasingMode = .multisampling4X
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // No dynamic updates needed for now.
    }
    
    private func makeScene() -> SCNScene {
        let scene = SCNScene()
        
        // Camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5.5)
        cameraNode.camera?.fieldOfView = 30
        scene.rootNode.addChildNode(cameraNode)
        
        // Key light (sun)
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.light?.intensity = 1200
        lightNode.position = SCNVector3(x: -3, y: 2, z: 5)
        scene.rootNode.addChildNode(lightNode)
        
        // Fill light
        let fillLightNode = SCNNode()
        fillLightNode.light = SCNLight()
        fillLightNode.light?.type = .ambient
        fillLightNode.light?.intensity = 200
        fillLightNode.light?.color = UIColor(white: 0.2, alpha: 1.0)
        scene.rootNode.addChildNode(fillLightNode)
        
        // Optional star particle system if present in bundle
        if let stars = SCNParticleSystem(named: "StarsParticles.scnp", inDirectory: nil) {
            scene.rootNode.addParticleSystem(stars)
        }
        
        // Earth node
        let earthNode = EarthNode()
        scene.rootNode.addChildNode(earthNode)
        
        return scene
    }
}

// MARK: - Earth node

final class EarthNode: SCNNode {
    override init() {
        super.init()
        
        let sphere = SCNSphere(radius: 1.0)
        sphere.segmentCount = 128
        
        if let material = sphere.firstMaterial {
            material.locksAmbientWithDiffuse = true
            
            // Texture names must match assets in the app bundle (e.g. in Assets.xcassets or EarthTextures folder).
            material.diffuse.contents = UIImage(named: "Diffuse")
            material.emission.contents = UIImage(named: "Emission")
            material.normal.contents = UIImage(named: "Normal")
            
            // No specular — removes the bright white dot on oceans
            material.specular.contents = nil
            material.shininess = 0
            material.isDoubleSided = false
        }
        
        self.geometry = sphere
        
        // Slow continuous rotation around the vertical axis.
        let rotationAction = SCNAction.rotate(
            by: 360 * CGFloat(Double.pi / 180),
            around: SCNVector3(x: 0, y: 1, z: 0),
            duration: 20.0
        )
        let repeatAction = SCNAction.repeatForever(rotationAction)
        self.runAction(repeatAction)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

