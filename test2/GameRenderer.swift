//
//  GameRenderer.swift
//  immersive office hours
//
//  Created by Patron on 4/9/25.
//

import RealityKit
import TabletopKit
import SwiftUI

@MainActor
class GameRenderer: TabletopGame.RenderDelegate {
    let root: Entity
    // The root offset controls the height of the table inside the app volume.
    let rootOffset: Vector3D = .init(x: 0, y: GameMetrics.tableThickness-1, z: 0)
    weak var game: Game?

    @MainActor
    init() {
        root = Entity()
        root.transform.translation = .init(rootOffset)

        let rotation = simd_quatf(angle: Float.pi / 4, axis: [0, 1, 0])
        root.transform.rotation = rotation
    }
}

