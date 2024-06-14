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
            for item in Attachments.allCases {
                if let attachment = attachments.entity(for: item) {
                    attachmentDict[item] = attachment
                }
            }
            for entity in await model.loadEntities(with: attachmentDict) {
                content.add(entity)
            }
        } attachments: {
            Attachment(id: Attachments.moveButtonStart) {
                MoveButton {
                    Task {
                        model.enterMoveState()
                    }
                }
            }
            Attachment(id: Attachments.moveButtonStop) {
                MoveStopButton {
                    Task {
                        model.leaveMoveState()
                    }
                }
            }
        }
        .gesture(DragGesture()
            .targetedToAnyEntity()
            .handActivationBehavior(.pinch)
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
        .gesture(TapGesture()
            .targetedToAnyEntity()
            .onEnded { value in
                model.activate(entity: value.entity)
            }
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

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(MuseumViewModel())
}
