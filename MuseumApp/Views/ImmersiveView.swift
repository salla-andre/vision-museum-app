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
    @State var model: MuseumViewModel

    var body: some View {
        // MARK: - View Setup
        RealityView { content, attachments in
            var attachmentDict: [Attachments : Entity] = [:]
            for attachment in Attachments.allCases {
                if let entity = attachments.entity(for: attachment) {
                    attachmentDict[attachment] = entity
                }
            }
            // We collect all the expected attachments and map them
            // so we can attach it to their corresponding entities
            for entity in await model.loadEntities(with: attachmentDict) {
                content.add(entity)
            }
            
            Task {
                // Run the ARKit session after the user opens the immersive space.
                await model.runARSession()
            }
        }
        // MARK: - Attachments
          attachments: {
            ForEach(Attachments.allCases, id: \.hashValue) { attachment in
                Attachment(id: attachment) {
                    switch attachment {
                        case .infoView(let item): 
                            InfoView(model: .init(item: item))
                        case.infoButtonHide(_):
                            HideInfoButton {
                                Task { model.hideInfo(for: attachment) }
                            }
                        case.infoButtonShow(_):
                            ShowInfoButton {
                                Task { model.showInfo(for: attachment) }
                            }
                    }
                }
            }
        }
        // MARK: - Gestures
        .gesture(
            LongPressGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    Task {
                        // After the long press finishes, we indicate the
                        // moving state have started.
                        await model.startMove(entity: value.entity)
                    }
                }
                .sequenced(
                    before: DragGesture()
                        .targetedToAnyEntity()
                        .simultaneously(
                            with: RotateGesture3D()
                                .targetedToAnyEntity()
                        )
                        .onChanged { value in
                            let drag = value.first
                            let rotate = value.second
                            
                            if let drag = drag {
                                model.move(
                                    entity: drag.entity,
                                    translate: drag.convert(
                                        drag.translation3D,
                                        from: .local,
                                        to: .scene
                                    )
                                )
                            }
                            
                            if let rotate = rotate {
                                model.rotate(
                                    entity: rotate.entity,
                                    with: rotate.rotation
                                )
                            }
                            
                        }
                        .onEnded { _  in
                            // After the drag/rotate finishes we stop the
                            // moving state and place the object in the
                            // corresponding anchor (if enabled)
                            model.stop()
                        }
                )
        )
        .onDisappear(perform: {
            // We reset the singleton so we can have a clean session
            // if the user reopens it.
            model.unload()
        })
    }
    
    // MARK: - Utilities
    func add(
        attachment attachmentType: Attachments,
        from attachmentObject: RealityViewAttachments,
        in attachmentDict: inout [Attachments : Entity]
    ) {
        if let attachment = attachmentObject.entity(for: attachmentType) {
            attachmentDict[attachmentType] = attachment
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView(
        model: MuseumViewModel()
    )
}
