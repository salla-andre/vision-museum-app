//
//  ActiveEntityModel.swift
//  MuseumApp
//
//  Created by André Salla on 13/06/24.
//

import Foundation
import RealityKit

enum ActiveEntityState {
    // Repositioning
    case move
    // Showing Buttons
    case idle
    // Presenting info view
    case presenting
}

class ActiveEntityModel {
    let entity: Entity
    var dragStartPoint: SIMD3<Float>? = nil
    var orientationStart: simd_quatf? = nil
    var moveOverlay: Entity? = nil
    var state: ActiveEntityState
    
    init(entity: Entity, state: ActiveEntityState, dragStartPoint: SIMD3<Float>? = nil) {
        self.entity = entity
        self.dragStartPoint = dragStartPoint
        self.state = state
    }
}
