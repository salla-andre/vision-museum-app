//
//  InfoView.swift
//  MuseumApp
//
//  Created by André Salla on 14/06/24.
//

import SwiftUI

struct InfoView: View {
    
    static let maxWidht: CGFloat = 700
    static let maxHeight: CGFloat = 600
    
    @State var model: InfoModel

    var body: some View {
        ScrollView {
            VStack {
                Text(model.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.extraLargeTitle)
                    .padding(.all)
                    .foregroundStyle(.infoText)
                
                Text(model.description)
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.all)
                    .foregroundStyle(.infoText)
            }
            .padding([.top, .bottom])
        }
        .background(.infoBackground)
        .glassBackgroundEffect()
        .frame(
            maxWidth: InfoView.maxWidht,
            maxHeight: InfoView.maxHeight
        )
    }
}

#Preview(windowStyle: .plain) {
    InfoView(model: InfoModel(item: .ballot))
}
