//
//  ARSessionManager.swift
//  MuseumApp
//
//  Created by André Salla on 15/06/24.
//

import ARKit
import RealityKit
import Foundation

@Observable
class ARSessionManager {
    
    var appState: AppState? = nil
    
    private var rootEntity: Entity? = nil
    
    // A map of world anchor UUIDs to the objects attached to them.
    private var anchoredObjects: [UUID: Entity] = [:]
    // A map of all current world anchors based on the anchor updates received from ARKit.
    private var worldAnchors: [UUID: WorldAnchor] = [:]
    // A map of world anchor UUIDs to the objects that are about to be attached to them.
    private var objectsBeingAnchored: [UUID: Entity] = [:]
    // A snapshot of the stored anchors from the persistence file
    private var anchorRawStorage: [UUID: String] = [:]
    
    var arkitSession = ARKitSession()
    var worldSensingAuthorizationStatus = ARKitSession.AuthorizationStatus.notDetermined
    var errorDetected = false
    
    // We just enable the ARSession if we have authorization and no error have been detected
    var enabled: Bool {
        worldSensingAuthorizationStatus == .allowed && !errorDetected
    }
    
    private let worldTracking = WorldTrackingProvider()
    
    // MARK: Public methods
    
    /// Static method to request authorization before we initialize an AR Session
    static func requestAuthorization() async {
        if WorldTrackingProvider.isSupported {
            _ = await ARKitSession().requestAuthorization(for: [.worldSensing])
        }
    }
    
    /// Starts a new ARSession if the permission was given by the user and starts listenning to anchor updates from the world provider
    func startSession() async {
        if WorldTrackingProvider.isSupported {
            let authorizationResult = await arkitSession.requestAuthorization(for: [.worldSensing])
            worldSensingAuthorizationStatus = authorizationResult[.worldSensing] ?? .notDetermined
            do {
                try await arkitSession.run([worldTracking])
            } catch {
                errorDetected = true
            }
        }
        Task.detached { [weak self] in
            guard let self else { return }
            for await anchorUpdate in self.worldTracking.anchorUpdates {
                await self.process(anchorUpdate)
            }
        }
    }
    
    /// Stops the AR Session and persists the current anchors
    func stopSession() {
        arkitSession.stop()
        writeStoredAnchors()
    }
    
    /// Reads the persisted anchor files and shows the objects that don't have a stored anchor
    /// The objects with stored anchors will be shown later, when the provider sets their positions
    func setupEntitiesForAnchoring(rootEntity: Entity) {
        self.rootEntity = rootEntity
        readStoredAnchors()
        Items.allCases.map { $0.entityGroupName }.forEach { groupName in
            if !anchorRawStorage.values.contains(where: { $0 == groupName }) {
                rootEntity
                    .findEntity(named: groupName)?
                    .components[OpacityComponent.self]?
                    .opacity = 1.0
            }
        }
    }

    /// Loads the persisted anchors from the persistence file
    func readStoredAnchors() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        guard let filePath = documentsDirectory.first?.appendingPathComponent("anchors.json"),
              FileManager.default.fileExists(atPath: filePath.path(percentEncoded: true)) else {
            return
        }

        guard let data = try? Data(contentsOf: filePath),
              let fileStorageObject = try? JSONDecoder().decode([UUID: String].self, from: data) else {
            return
        }
        anchorRawStorage = fileStorageObject
    }
    
    /// Write the existing anchors from the memory to the persistence file
    func writeStoredAnchors() {
        var worldAnchorsToFileNames: [UUID: String] = [:]
        for (anchorID, object) in anchoredObjects {
            worldAnchorsToFileNames[anchorID] = object.name
        }
        
        let encoder = JSONEncoder()
        guard let jsonString = try? encoder.encode(worldAnchorsToFileNames) else { return }
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsDirectory.appendingPathComponent("anchors.json")

        try? jsonString.write(to: filePath)
    }
    
    @MainActor
    /// Attaches an object after the user moves it
    func attachItem(entity: Entity) async {
        // First, create a new world anchor and try to add it to the world tracking provider.
        let anchor = WorldAnchor(originFromAnchorTransform: entity.transformMatrix(relativeTo: nil))
        objectsBeingAnchored[anchor.id] = entity
        do {
            try await worldTracking.addAnchor(anchor)
        } catch {
            objectsBeingAnchored.removeValue(forKey: anchor.id)
            return
        }
    }
    
    @MainActor
    /// Dettaches an object before the user moves it
    func detachItem(entity: Entity) {
        guard let anchorID = anchoredObjects.first(where: { $0.value === entity })?.key else {
            return
        }
        // Remove the object from the set of anchored objects because it’s about to be moved.
        anchoredObjects.removeValue(forKey: anchorID)
        Task {
            // The world anchor is no longer needed; remove it so that it doesn't
            // remain in the app’s list of world anchors forever.
            try? await worldTracking.removeAnchor(forID: anchorID)
        }
    }
    
    // MARK: Private methods
    
    @MainActor
    /// Processes the anchors updates provided by the WorldProvider
    private func process(_ anchorUpdate: AnchorUpdate<WorldAnchor>) {
        let anchor = anchorUpdate.anchor
        
        if anchorUpdate.event != .removed {
            worldAnchors[anchor.id] = anchor
        } else {
            worldAnchors.removeValue(forKey: anchor.id)
        }
        
        switch anchorUpdate.event {
        case .added:
            if let storedEntityName = anchorRawStorage[anchor.id] {
                // Items anchored in previous session needs to be repositioned
                if let entity = rootEntity?.findEntity(named: storedEntityName) {
                    setValues(entity: entity, anchor: anchor)
                    entity.components[OpacityComponent.self]?.opacity = 1.0
                    anchoredObjects[anchor.id] = entity
                }
            } else if let objectBeingAnchored = objectsBeingAnchored[anchor.id] {
                // We don't need to set the position when updating because
                // that was already made by the user
                objectsBeingAnchored.removeValue(forKey: anchor.id)
                anchoredObjects[anchor.id] = objectBeingAnchored
            } else {
                if anchoredObjects[anchor.id] == nil {
                    Task {
                        // Immediately delete world anchors for which no placed object is known.
                        try? await worldTracking.removeAnchor(forID: anchor.id)
                    }
                }
            }
            fallthrough
        case .updated:
            // Keep the position of placed objects in sync with their corresponding
            // world anchor, and hide the object if the anchor isn’t tracked.
            setValues(entity: anchoredObjects[anchor.id], anchor: anchor)

        case .removed:
            // Remove the placed object if the corresponding world anchor was removed.
            let object = anchoredObjects[anchor.id]
            object?.removeFromParent()
            anchoredObjects.removeValue(forKey: anchor.id)
        }
    }
    
    private func setValues(entity: Entity?, anchor: WorldAnchor) {
        let xyzMask = SIMD3(0, 1, 2)
        let origin = anchor.originFromAnchorTransform
        entity?.position = origin
            .columns.3[xyzMask]
            // We don't want to change the Y position, so we replace it with 0
            // because sometimes the World Anchor returns a different value
            // if it wrongly determines the anchor position in the current
            // session.
            .replacing(with: [0.0, 0.0, 0.0], where: [false, true, false])
        
        let rotationMatrix = matrix_float3x3(origin.columns.0[xyzMask],
                                             origin.columns.1[xyzMask],
                                             origin.columns.2[xyzMask])
        
        entity?.orientation = simd_quatf(rotationMatrix)
        entity?.isEnabled = anchor.isTracked
    }
}
