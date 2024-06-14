//
//  InfoView.swift
//  MuseumApp
//
//  Created by André Salla on 14/06/24.
//

import SwiftUI

struct InfoView: View {
    
    @State var model: InfoViewModel

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
        .frame(maxWidth: 700, maxHeight: 600)
    }
}

#Preview(windowStyle: .plain) {
    InfoView(model: InfoViewModel(item: .ballot))
}
