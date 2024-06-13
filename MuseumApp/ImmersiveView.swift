//
//  ImmersiveView.swift
//  MuseumApp
//
//  Created by André Salla on 10/06/24.
//

import SwiftUI
import ARKit
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @Environment(MuseumViewModel.self) var model

    var body: some View {
        RealityView { content in
            if let entity = try? await Entity(named: "ImmersiveScene", in: realityKitContentBundle) {
                content.add(entity)

                // Add an ImageBasedLight for the immersive content
                guard let resource = try? await EnvironmentResource(named: "Sunlight") else { return }
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
                
                content.add(floor)
            }
        }
        .gesture(DragGesture()
            .targetedToAnyEntity()
            .handActivationBehavior(.pinch)
            .onChanged { value in
                if model.dragStartPoint == nil {
                    model.dragStartPoint = value.entity.position
                }
                let point = value.convert(value.translation3D, from: .local, to: .scene)
                value.entity.position = model.dragStartPoint! + SIMD3(
                    x: point.x,
                    y: value.entity.position.y,
                    z: point.z
                )
            }
            .onEnded({ _  in
                model.dragStartPoint = nil
            })
        )
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(MuseumViewModel())
}
