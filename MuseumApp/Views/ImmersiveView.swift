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
        RealityView { content, attachments in
            var attachmentDict: [Attachments : Entity] = [:]
            for attachment in Attachments.allCases {
                if let entity = attachments.entity(for: attachment) {
                    attachmentDict[attachment] = entity
                }
            }
            for entity in await model.loadEntities(with: attachmentDict) {
                content.add(entity)
            }
        } attachments: {
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
        .gesture(
            LongPressGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    model.startMove(entity: value.entity)
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
                            model.stop()
                        }
                )
        )
    }
    
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
    ImmersiveView()
        .environment(MuseumViewModel())
}
