//
//  MuseumViewModel.swift
//  MuseumApp
//
//  Created by André Salla on 12/06/24.
//

import Foundation
import RealityKit
import RealityKitContent
import Spatial

@Observable
@MainActor
final class MuseumViewModel {

    private var attachments: [Attachments : Entity] = [:]
    private var activeEntity: ActiveEntityModel?

    func loadEntities(with attachments: [Attachments: Entity]) async -> [Entity] {
        var content: [Entity] = []
        
        if let entity = try? await Entity(named: "ImmersiveScene", in: realityKitContentBundle) {
            content.append(entity)

            prepare(attachments: attachments, at: entity)
        }
        
        return content
    }

    func hide(attachment: Attachments) {

    }

    func show(attachment: Attachments) {
        
    }

    func move(entity: Entity, translate translation3D: SIMD3<Float>) {
        guard let activeEntity = activeEntity,
              activeEntity.entity == entity,
              activeEntity.state == .move,
              let startPoint = activeEntity.dragStartPoint
        else { return }

         entity.position = startPoint + SIMD3(
             x: translation3D.x,
             y: entity.position.y,
             z: translation3D.z
         )
    }
    
    func stop() {
        activeEntity?.moveOverlay?.removeFromParent()
        activeEntity = nil
    }

    func startMove(entity: Entity) {
        guard activeEntity == nil else { return }
        
        let activeModel = ActiveEntityModel(entity: entity, state: .move)
        activeEntity = activeModel

        activeModel.dragStartPoint = entity.position
        
        let extraSpace: Float = 0.05
        
        // adding extra 5 cm so the overlay doesn't colide with its parent
        let extends =
            activeModel.entity.visualBounds(relativeTo: entity).extents +
            [extraSpace, extraSpace, extraSpace]
        let overlay = ModelEntity(
            mesh: .generateBox(width: extends.x, height: extends.y, depth: extends.z, cornerRadius: 0.025),
            materials: [SimpleMaterial(color: .gray.withAlphaComponent(0.75), isMetallic: false)]
        )
        overlay.components.set(OpacityComponent(opacity: 0.3))
        activeModel.moveOverlay = overlay
        entity.addChild(overlay)
        overlay.position = SIMD3(x: 0.0, y: (extends.y / 2.0) - 0.025, z: 0.0)
    }
    
    private func addAttachment(
        _ attachment: Entity?,
        to entity: Entity?,
        with extraX: Float = 0.0,
        and extraY: Float = 0.0,
        position: AttachmentPosition
    ) {
        guard let attachment = attachment, let entity = entity else { return }
        let extents = entity.visualBounds(relativeTo: entity).extents
        // aligned with the left border with 10 cm of space between the atachment and the entity
        let attachmentX =  ((extents.x / 2.0) + extraX + 0.1) * (position == .left ? -1 : 1)
        // the center of the entity height
        let attachmentY = extents.y + extraY
        
        attachment.removeFromParent()
        
        // Z is zero because we want it to be centered to the entity depth
        attachment.position = SIMD3(x: attachmentX, y: attachmentY, z: 0.0)
        entity.addChild(attachment)
    }
    
    private func prepare(attachments: [Attachments: Entity], at entity: Entity) {
        self.attachments = attachments
        attachments.forEach { (id, attachment) in
            guard
                case let .infoView(item) = id,
                let itemEntity = entity.findEntity(named: item.entityGroupName)
            else { return }
            attachment.components.set(OpacityComponent(opacity: 1.0))
            addAttachment(
                attachment,
                to: itemEntity,
                // half of width from point to meters
                with: (Float(InfoView.maxWidht) / 2000) / 2,
                and: (((Float(InfoView.maxHeight) / 2000) / 2) + 0.1) * -1,
                position: .right)
        }
    }
}
