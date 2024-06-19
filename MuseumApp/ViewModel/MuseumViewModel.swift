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

    // Map of all available Attachments and their corresponding entities
    private var attachments: [Items : Entity] = [:]
    // The moving entity while dragging/rotating
    private var activeEntity: ActiveEntityModel?
    // The rootEntity loaded from RealityKit Content
    private var rootEntity: Entity?
    
    var sessionManager: ARSessionManager?

    // MARK: - Setup
    
    /// Loads the ImmersiveScene, adds the attachments to their corresponding childs and prepares
    /// the entity to be shown.
    func loadEntities(with attachments: [Items: Entity]) async -> [Entity] {
        var content: [Entity] = []
        
        if let entity = try? await Entity(named: "ImmersiveScene", in: realityKitContentBundle) {
            content.append(entity)

            // Occluded floor
            let floor = ModelEntity(
                mesh: .generatePlane(width: 100, depth: 100),
                materials: [OcclusionMaterial()]
            )
            floor.generateCollisionShapes(recursive: false)
            floor.components[PhysicsBodyComponent.self] = .init(
              massProperties: .default,
              mode: .static
            )
            
            content.append(floor)
            
            rootEntity = entity
            // Hide and place the attachments along their corresponding entities
            prepare(attachments: attachments)
            // Hide all items so we can wait for their positions to load from
            // saved Anchors before they appear in the screen.
            hideAllItems()
            sessionManager = ARSessionManager()
        }
        
        return content
    }
    
    /// Resets the Model state and stop all active AR sessions
    func unload() {
        sessionManager?.stopSession()
        sessionManager = nil
        attachments = [:]
        activeEntity = nil
        rootEntity = nil
    }
    
    private func addAttachment(
        _ attachment: Entity?,
        to entity: Entity?
    ) {
        guard let attachment = attachment, let entity = entity else { return }
        let extents = entity.visualBounds(relativeTo: entity).extents
        // aligned with the left border with 10 cm of space between the atachment and the entity
        let attachmentX =  ((extents.x / 2.0) + 0.25)
        // the center of the entity height
        let attachmentY = extents.y
        
        attachment.removeFromParent()
        
        // Z is zero because we want it to be centered to the entity depth
        attachment.position = SIMD3(x: attachmentX, y: attachmentY, z: 0.0)
        entity.addChild(attachment)
    }
    
    private func prepare(attachments: [Items: Entity]) {
        self.attachments = attachments
        attachments.forEach { (id, attachment) in
            guard let itemEntity = rootEntity?.findEntity(named: id.entityGroupName) else { return }
            attachment.components.set(OpacityComponent(opacity: 1.0))
            addAttachment(attachment, to: itemEntity)
        }
    }
    
    // MARK: - Gesture Handlers

    /// Moves the given entity to the indicated point
    func move(entity: Entity, translate translation3D: SIMD3<Float>) {
        guard let activeEntity = activeEntity,
              activeEntity.entity == entity,
              let startPoint = activeEntity.dragStartPoint
        else { return }
        activeEntity.isDragging = true

         entity.position = startPoint + SIMD3(
             x: translation3D.x,
             y: entity.position.y,
             z: translation3D.z
         )
    }
    
    /// Rotates the given entity with the given 3D rotation info
    func rotate(entity: Entity, with rotation: Rotation3D) {
        guard let activeEntity = activeEntity,
              activeEntity.entity == entity
        else { return }
        activeEntity.isDragging = true

        let flippedRotation = Rotation3D(angle: rotation.angle,
                                         // we just allow the rotation over the Y axis
                                         axis: RotationAxis3D(x: Rotation3D.identity.axis.x,
                                                              y: rotation.axis.y,
                                                              z: Rotation3D.identity.axis.z))

        let newOrientation = Rotation3D.identity.rotated(by: flippedRotation)
        entity.setOrientation(.init(newOrientation), relativeTo: nil)
                              
    }
    
    /// Starts the Movement State and displays the Movement container over the moving element
    func startMove(entity: Entity) async {
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
        // We create a box to act as a Movement container while the user is moving the object
        let overlay = ModelEntity(
            mesh: .generateBox(width: extends.x, height: extends.y, depth: extends.z, cornerRadius: 0.025),
            materials: [SimpleMaterial(color: .gray.withAlphaComponent(0.75), isMetallic: false)]
        )
        overlay.components.set(OpacityComponent(opacity: 0.3))
        activeModel.moveOverlay = overlay
        entity.addChild(overlay)
        overlay.position = SIMD3(x: 0.0, y: (extends.y / 2.0) - 0.025, z: 0.0)
        
        if sessionManager?.enabled ?? false{
            // Before start moving, we detach the anchor so it can be updated when the new position is set.
            sessionManager?.detachItem(entity: entity)
        }
        
        // Await for the first movement to happen in 1.5 seconds.
        // After that, cancels the movement if it hasn't started yet.
        do {
            try await Task.sleep(nanoseconds: 1_500_000_000)
            if !activeModel.isDragging {
                stop()
            }
        } catch {
            print(error)
        }
    }
    
    /// Stops the moving state, persists the new position anchor and removes the moving container
    func stop() {
        if sessionManager?.enabled ?? false {
            Task {
                if let entity = activeEntity?.entity {
                    await sessionManager?.attachItem(entity: entity)
                }
                activeEntity?.moveOverlay?.removeFromParent()
                activeEntity = nil
            }
        } else {
            activeEntity?.moveOverlay?.removeFromParent()
            activeEntity = nil
        }
    }
    
    // MARK: - Attachments
    
    /// Hides all objects in the Immersive View
    func hideAllItems() {
        guard let rootEntity = rootEntity else { return }
        Items.allCases.forEach { item in
            guard let itemEntity = rootEntity.findEntity(named: item.entityGroupName) else { return }
            itemEntity.components.set(OpacityComponent(opacity: 0.0))
        }
    }
    
    // MARK: World Anchor
    
    /// Starts the AR Session and setup it for the loaded entities
    func runARSession() async {
        guard let rootEntity = rootEntity else { return }
        sessionManager?.setupEntitiesForAnchoring(rootEntity: rootEntity)
        await sessionManager?.startSession()
        guard sessionManager?.enabled ?? false else { return }
        Task.detached { [weak self] in
            guard let self else { return }
            await self.run(
                function: self.updateRelativeToDevicePosition,
                withFrequency: 90
            )
        }
    }
    
    func updateRelativeToDevicePosition() async {
        await sessionManager?
            .updateRelativeToDevicePosition(
                attachments: Array(attachments.values)
            )
    }
    
    @MainActor
    func run(function: () async -> Void, withFrequency hz: UInt64) async {
        while true {
            if Task.isCancelled {
                return
            }
            
            // Sleep for 1 s / hz before calling the function.
            let nanoSecondsToSleep: UInt64 = NSEC_PER_SEC / hz
            do {
                try await Task.sleep(nanoseconds: nanoSecondsToSleep)
            } catch {
                // Sleep fails when the Task is cancelled. Exit the loop.
                return
            }
            
            await function()
        }
    }
}
