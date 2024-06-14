//
//  MoveStopButton.swift
//  MuseumApp
//
//  Created by André Salla on 13/06/24.
//

import SwiftUI

struct MoveStopButton: View {
    var handler: (() -> Void)?

    var body: some View {
        Button {
            if let handler {
                handler()
            }
        } label: {
            Image(systemName: "checkmark")
                .resizable(resizingMode: .stretch)
                .padding(25)
                .frame(width: 100, height: 100)
        }
        .tint(Color("ConfirmColor"))
        .foregroundStyle(.white)
        .glassBackgroundEffect()
    }
}

#Preview(windowStyle: .plain) {
    MoveStopButton()
        .preferredColorScheme(.light)
}
