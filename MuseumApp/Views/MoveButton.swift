//
//  MoveButton.swift
//  MuseumApp
//
//  Created by André Salla on 13/06/24.
//

import SwiftUI

struct MoveButton: View {
    var handler: (() -> Void)?

    var body: some View {
        Button {
            if let handler {
                handler()
            }
        } label: {
            Image(systemName: "move.3d")
                .resizable(resizingMode: .stretch)
                .padding(25)
                .frame(width: 100, height: 100)
        }
        .tint(Color("MoveColor"))
        .foregroundStyle(.white)
        .glassBackgroundEffect()
    }
}

#Preview(windowStyle: .plain) {
    MoveButton()
        .preferredColorScheme(.light)
}
