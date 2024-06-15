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

    func move(entity: Entity, translate translation3D: SIMD3<Float>) {
        guard let activeEntity = activeEntity,
              activeEntity.entity == entity,
              let startPoint = activeEntity.dragStartPoint
        else { return }

         entity.position = startPoint + SIMD3(
             x: translation3D.x,
             y: entity.position.y,
             z: translation3D.z
         )
    }
    
    func rotate(entity: Entity, with rotation: Rotation3D) {
        guard let activeEntity = activeEntity,
              activeEntity.entity == entity
        else { return }

        let flippedRotation = Rotation3D(angle: rotation.angle,
                                         axis: RotationAxis3D(x: Rotation3D.identity.axis.x,
                                                              y: rotation.axis.y,
                                                              z: Rotation3D.identity.axis.z))

        let newOrientation = Rotation3D.identity.rotated(by: flippedRotation)
        entity.setOrientation(.init(newOrientation), relativeTo: nil)
                              
    }
    
    func stop() {
        activeEntity?.moveOverlay?.removeFromParent()
        activeEntity = nil
    }
    
    func showInfo(for attachment: Attachments) {
        toggle(attachment: attachment)
    }
    
    func hideInfo(for attachment: Attachments) {
        toggle(attachment: attachment, hide: true)
    }

    func startMove(entity: Entity) {
        guard activeEntity == nil else { return }
        
        let activeModel = ActiveEntityModel(entity: entity)
        activeEntity = activeModel

        activeModel.dragStartPoint = entity.position
        activeModel.orientationStart = entity.orientation(relativeTo: nil)
        
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
            guard let itemEntity = entity.findEntity(named: id.item.entityGroupName) else { return }
            
            attachment.components.set(OpacityComponent(opacity: id.isShow ? 1.0 : 0.0))
            
            let adjustments: (width: Float, height: Float) = if case .infoView(_) = id {
                (
                    width: (Float(InfoView.maxWidht) / 2000) / 2,
                    height: (((Float(InfoView.maxHeight) / 2000) / 2) + 0.1) * -1
                )
            } else {
                (
                    width: -0.025,
                    height: 0.025
                )
            }

            addAttachment(
                attachment,
                to: itemEntity,
                // half of width from point to meters
                with: adjustments.width,
                and: adjustments.height,
                position: .right)
        }
    }
    
    private func toggle(attachment: Attachments, hide: Bool = false) {
        guard let entity = attachments[attachment] else { return }

        entity.components[OpacityComponent.self]?.opacity = 0.0
        
        if let oppositeAttachment = attachment.opposite {
            attachments[oppositeAttachment]?
                .components[OpacityComponent.self]?
                .opacity = 1.0
        }
        
        attachments[.infoView(item: attachment.item)]?
            .components[OpacityComponent.self]?
            .opacity = hide ? 0.0 : 1.0
    }
}
