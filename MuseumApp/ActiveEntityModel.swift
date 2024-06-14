//
//  ActiveEntityModel.swift
//  MuseumApp
//
//  Created by André Salla on 13/06/24.
//

import Foundation
import RealityKit

enum ActiveEntityState {
    case move
    case show
    case disabled
}

class ActiveEntityModel {
    let entity: Entity
    var dragStartPoint: SIMD3<Float>? = nil
    var moveOverlay: Entity? = nil
    var state: ActiveEntityState
    
    init(entity: Entity, state: ActiveEntityState, dragStartPoint: SIMD3<Float>? = nil) {
        self.entity = entity
        self.dragStartPoint = dragStartPoint
        self.state = state
    }
}
