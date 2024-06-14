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
            Attachment(id: Attachments.infoButtonShow) {
                ShowInfoButton {
                    Task {
                        model.show(attachment: .infoButtonShow)
                    }
                }
            }
            Attachment(id: Attachments.infoButtonHide) {
                HideInfoButton {
                    Task {
                        model.hide(attachment: .infoButtonHide)
                    }
                }
            }
            Attachment(id: Attachments.infoView(item: .ballot)) {
                InfoView(model: .init(item: .ballot))
            }
            Attachment(id: Attachments.infoView(item: .bust)) {
                InfoView(model: .init(item: .bust))
            }
            Attachment(id: Attachments.infoView(item: .vase)) {
                InfoView(model: .init(item: .vase))
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
                        .onChanged { value in
                            model.move(
                                entity: value.entity,
                                translate: value.convert(
                                    value.translation3D,
                                    from: .local,
                                    to: .scene
                                )
                            )
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
