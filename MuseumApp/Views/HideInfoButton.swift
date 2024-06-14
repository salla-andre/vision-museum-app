//
//  HideInfoButton.swift
//  MuseumApp
//
//  Created by André Salla on 14/06/24.
//

import SwiftUI

struct HideInfoButton: View {
    var handler: (() -> Void)?
    
    var body: some View {
        Button {
            if let handler {
                handler()
            }
        } label: {
            Image(systemName: "eye.slash")
                .resizable(resizingMode: .stretch)
                .padding([.top, .bottom], 25)
                .padding([.leading, .trailing], 20)
                .frame(width: 100, height: 100)
        }
        .tint(.infoBackground)
        .foregroundStyle(.btnClose)
        .glassBackgroundEffect()
    }
}

#Preview(windowStyle: .plain) {
    HideInfoButton()
        .preferredColorScheme(.light)
}
