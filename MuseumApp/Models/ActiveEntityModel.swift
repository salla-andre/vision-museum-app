//
//  ActiveEntityModel.swift
//  MuseumApp
//
//  Created by André Salla on 13/06/24.
//

import Foundation
import RealityKit

class ActiveEntityModel {
    let entity: Entity
    var dragStartPoint: SIMD3<Float>? = nil
    var orientationStart: simd_quatf? = nil
    var activeAttachmentsStart: [Attachments] = []
    var moveOverlay: Entity? = nil
    
    init(entity: Entity) {
        self.entity = entity
    }
}
