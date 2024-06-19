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
        VStack {
            Button {
                withAnimation {
                    model.state = model.state == .hide ? .showing : .hide
                }
            } label: {
                Image(systemName: model.state == .hide ? "plus.magnifyingglass" : "minus.magnifyingglass")
                    .resizable(resizingMode: .stretch)
                    .padding(20)
                    .frame(width: 100, height: 100)
            }
            .tint(.infoBackground)
            .foregroundStyle(model.state == .hide ? .infoText : .btnClose)
            .glassBackgroundEffect()
            .frame(maxWidth: InfoView.maxWidht, alignment: .leading)
            if model.state == .showing {
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
                .transition(
                    AnyTransition
                        .opacity
                        .combined(
                            with: .scale
                        )
                )
            }
        }
    }
}

#Preview(windowStyle: .plain) {
    InfoView(model: InfoModel(item: .ballot))
}
