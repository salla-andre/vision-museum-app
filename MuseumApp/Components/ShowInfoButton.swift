//
//  ShowInfoButton.swift
//  MuseumApp
//
//  Created by André Salla on 14/06/24.
//

import SwiftUI

struct ShowInfoButton: View {
    var handler: (() -> Void)?

    var body: some View {
        Button {
            if let handler {
                handler()
            }
        } label: {
            Image(systemName: "eye")
                .resizable(resizingMode: .stretch)
                .padding([.top, .bottom], 30)
                .padding([.leading, .trailing], 20)
                .frame(width: 100, height: 100)
        }
        .tint(.infoBackground)
        .foregroundStyle(.infoText)
        .glassBackgroundEffect()
    }
}

#Preview(windowStyle: .plain) {
    ShowInfoButton()
        .preferredColorScheme(.light)
}
