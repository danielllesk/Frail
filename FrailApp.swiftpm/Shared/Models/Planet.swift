//
//  Planet.swift
//  Frail
//
//  Simple model for a planet in the Build scene.
//

import Foundation

struct Planet: Identifiable {
    let id: Int
    var mass: Double
    var orbitalRadius: Double
    
    init(id: Int, mass: Double = 1.0, orbitalRadius: Double = 1.0) {
        self.id = id
        self.mass = mass
        self.orbitalRadius = orbitalRadius
    }
    
    // Derived size for SceneKit sphere
    var visualSize: Double {
        // Logarithmic or root scale so mass=5 isn't 50x bigger than mass=0.1
        // Baseline: Earth mass (1.0) -> size 1.0
        return 0.5 + (sqrt(mass) * 0.5)
    }
}
