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
class MuseumViewModel {
    var dragStartPoint: SIMD3<Float>? = nil
    private var attachments: [Attachments : Entity] = [:]
    private var activeEntity: ActiveEntityModel?
    
    func loadEntities(with attachments: [Attachments: Entity]) async -> [Entity] {
        var content: [Entity] = []
        
        if let entity = try? await Entity(named: "ImmersiveScene", in: realityKitContentBundle) {
            content.append(entity)

            // Add an ImageBasedLight for the immersive content
            guard let resource = try? await EnvironmentResource(named: "Sunlight") else { return content }
            let iblComponent = ImageBasedLightComponent(source: .single(resource), intensityExponent: 0.25)
            entity.components.set(iblComponent)
            entity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: entity))
            
            /* Occluded floor */
            let floor = ModelEntity(mesh: .generatePlane(width: 100, depth: 100), materials: [OcclusionMaterial()])
            floor.generateCollisionShapes(recursive: false)
            floor.components[PhysicsBodyComponent.self] = .init(
                massProperties: .default,
                mode: .static
            )
            
            self.attachments = attachments
            
            content.append(floor)
        }
        
        return content
    }
    
    func activate(entity: Entity) {
        if let activeEntity = activeEntity {
            if activeEntity.entity == entity && activeEntity.state == .show {
                hide()
            }
            return
        }
        show(entity: entity)
    }
    
    func hide() {
        attachments.values.forEach { attachment in
            attachment.removeFromParent()
        }
        activeEntity = nil
    }
    
    func addMoveAttachment(_ attachment: Entity?, to entity: Entity?, with extra: Float = 0.0) {
        guard let attachment = attachment, let entity = entity else { return }
        // aligned with the left border with 10 cm of space between the atachment and the entity
        let attachmentX =  -((entity.visualBounds(relativeTo: entity).extents.x - extra) / 2.0) - 0.1
        // the center of the entity height
        let attachmentY = ((entity.visualBounds(relativeTo: entity).extents.y - extra) / 2.0)
        
        attachment.removeFromParent()
        
        // Z is zero because we want it to be centered to the entity depth
        attachment.position = SIMD3(x: attachmentX, y: attachmentY, z: 0.0)
        entity.addChild(attachment)
    }
    
    func show(entity: Entity) {
        activeEntity = ActiveEntityModel(entity: entity, state: .show)
        attachments[.moveButtonStop]?.removeFromParent()
        addMoveAttachment(attachments[.moveButtonStart], to: entity)
    }
    
    func enterMoveState() {
        guard let activeEntity = activeEntity,
              activeEntity.state == .show
        else { return }
        activeEntity.dragStartPoint = activeEntity.entity.position
        activeEntity.state = .move
        
        let extraSpace: Float = 0.05
        
        // adding extra 5 cm so the overlay doesn't colide with its parent
        let extends = activeEntity.entity.visualBounds(relativeTo: activeEntity.entity).extents + [extraSpace, extraSpace, extraSpace]
        let overlay = ModelEntity(
            mesh: .generateBox(width: extends.x, height: extends.y, depth: extends.z),
            materials: [SimpleMaterial(color: .gray.withAlphaComponent(0.75), isMetallic: false)]
        )
        overlay.components.set(OpacityComponent(opacity: 0.3))
        activeEntity.moveOverlay = overlay
        activeEntity.entity.addChild(overlay)
        overlay.position = SIMD3(x: 0.0, y: extends.y / 2.0, z: 0.0)

        attachments[.moveButtonStart]?.removeFromParent()
        addMoveAttachment(attachments[.moveButtonStop], to: activeEntity.entity, with: extraSpace)
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
        activeEntity?.dragStartPoint = nil
    }
    
    func leaveMoveState() {
        activeEntity?.dragStartPoint = nil
        activeEntity?.state = .show
        activeEntity?.moveOverlay?.removeFromParent()
        activeEntity?.moveOverlay = nil
        attachments[.moveButtonStop]?.removeFromParent()
        addMoveAttachment(attachments[.moveButtonStart], to: activeEntity?.entity)
    }
}
