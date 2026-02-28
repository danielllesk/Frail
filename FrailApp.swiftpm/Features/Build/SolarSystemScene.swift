//
//  SolarSystemScene.swift
//  Frail
//
//  3D SceneKit view for the Build section.
//

import SwiftUI
import SceneKit

struct SolarSystemScene: UIViewRepresentable {
    let gravity: Double
    let lightSpeed: Double
    let starType: PhysicsConstants.StarType
    let planets: [Planet]
    let zoomScale: CGFloat
    let universeName: String
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = .clear
        scnView.antialiasingMode = .multisampling4X
        
        let scene = SCNScene()
        
        // 1. Setup Camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.name = "camera"
        cameraNode.camera?.zFar = 1000
        // Base position
        cameraNode.position = SCNVector3(x: 0, y: 15, z: 25)
        cameraNode.eulerAngles = SCNVector3(x: -.pi/4, y: 0, z: 0)
        scene.rootNode.addChildNode(cameraNode)
        
        // 2. Setup Lighting
        let omniLight = SCNLight()
        omniLight.type = .omni
        omniLight.intensity = 2000
        let lightNode = SCNNode()
        lightNode.light = omniLight
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 200
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)
        
        // 3. Setup Star
        let starNode = SCNNode(geometry: SCNSphere(radius: 2.0))
        starNode.name = "star"
        starNode.geometry?.firstMaterial?.lightingModel = .constant
        scene.rootNode.addChildNode(starNode)
        
        // 4. Setup Universe Title (Star Wars Style)
        let textGeometry = SCNText(string: universeName.uppercased(), extrusionDepth: 1.0)
        textGeometry.font = UIFont.systemFont(ofSize: 10, weight: .black)
        textGeometry.flatness = 0.1
        textGeometry.firstMaterial?.diffuse.contents = UIColor(red: 0xC9/255.0, green: 0xA8/255.0, blue: 0x4C/255.0, alpha: 0.6) // frailGold
        textGeometry.firstMaterial?.lightingModel = .constant
        
        let titleNode = SCNNode(geometry: textGeometry)
        titleNode.name = "universe_title"
        
        // Center the text
        let (min, max) = textGeometry.boundingBox
        titleNode.pivot = SCNMatrix4MakeTranslation((max.x - min.x) / 2 + min.x, (max.y - min.y) / 2 + min.y, 0)
        
        // Position back and angled
        titleNode.position = SCNVector3(x: 0, y: -10, z: -80)
        titleNode.eulerAngles = SCNVector3(x: -.pi/3, y: 0, z: 0)
        titleNode.scale = SCNVector3(x: 2, y: 2, z: 2)
        scene.rootNode.addChildNode(titleNode)
        
        // 5. Setup Planets
        for i in planets.indices {
            let container = SCNNode()
            container.name = "orbit_container_\(i)"
            scene.rootNode.addChildNode(container)
            
            let planetNode = SCNNode(geometry: SCNSphere(radius: 0.5))
            planetNode.name = "planet_\(i)"
            planetNode.position = SCNVector3(x: 10 + Float(i) * 10, y: 0, z: 0)
            
            // Basic material
            let mat = SCNMaterial()
            mat.diffuse.contents = UIColor.systemGray
            planetNode.geometry?.materials = [mat]
            
            container.addChildNode(planetNode)
            
            // Add orbit ring
            let orbitTorus = SCNTorus(ringRadius: CGFloat(planetNode.position.x), pipeRadius: 0.05)
            let ringNode = SCNNode(geometry: orbitTorus)
            ringNode.opacity = 0.15
            ringNode.name = "ring_\(i)"
            scene.rootNode.addChildNode(ringNode)
        }
        
        scnView.scene = scene
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        guard let scene = scnView.scene else { return }
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.8
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // Update Title
        if let title = scene.rootNode.childNode(withName: "universe_title", recursively: false),
           let textGeo = title.geometry as? SCNText {
            textGeo.string = universeName.uppercased()
            let (min, max) = textGeo.boundingBox
            title.pivot = SCNMatrix4MakeTranslation((max.x - min.x) / 2 + min.x, (max.y - min.y) / 2 + min.y, 0)
        }
        
        // Update Camera Zoom
        if let camera = scene.rootNode.childNode(withName: "camera", recursively: false) {
            // Adjust distance based on zoomScale
            let baseDistance: Float = 35.0 // Increased base distance
            let targetZ = baseDistance / Float(zoomScale)
            let targetY = (targetZ * 20.0 / 35.0) 
            camera.position = SCNVector3(x: 0, y: targetY, z: targetZ)
        }
        
        // Update Star
        if let star = scene.rootNode.childNode(withName: "star", recursively: false) {
            star.geometry?.firstMaterial?.diffuse.contents = starType.starColor
            
            // Size star based on type
            let radius: CGFloat = (starType == .blueGiant) ? 4.5 : (starType == .whiteDwarf ? 1.0 : 2.5)
            (star.geometry as? SCNSphere)?.radius = radius
        }
        
        // Update Planets
        for (i, planet) in planets.enumerated() {
            if let planetNode = scene.rootNode.childNode(withName: "planet_\(i)", recursively: true),
               let ringNode = scene.rootNode.childNode(withName: "ring_\(i)", recursively: false) {
                
                let baseRadius = 8.0 + Double(i) * 12.0 // Significantly more spacing
                let actualRadius = baseRadius * planet.orbitalRadius * (1.1 - 0.1 * gravity)
                
                planetNode.position.x = Float(actualRadius)
                (planetNode.geometry as? SCNSphere)?.radius = CGFloat(planet.visualSize * 0.6)
                
                // Update ring
                if let torus = ringNode.geometry as? SCNTorus {
                    torus.ringRadius = CGFloat(actualRadius)
                }
                
                // Rotation
                let baseDuration = 8.0 + Double(i) * 6.0
                let actualDuration = baseDuration / max(0.1, lightSpeed)
                
                let actionKey = "orbit"
                if planetNode.parent?.action(forKey: actionKey) == nil || context.coordinator.lastLightSpeed != lightSpeed {
                    planetNode.parent?.removeAction(forKey: actionKey)
                    let action = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: .pi * 2, z: 0, duration: actualDuration))
                    planetNode.parent?.runAction(action, forKey: actionKey)
                }
            }
        }
        
        context.coordinator.lastLightSpeed = lightSpeed
        SCNTransaction.commit()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var lastLightSpeed: Double = 1.0
    }
}
