//
//  ContentView.swift
//  MuseumApp
//
//  Created by André Salla on 10/06/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @State private var showImmersiveSpace = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(AppState.self) var appState

    var body: some View {
        VStack {
            Model3D(named: "Scene", bundle: realityKitContentBundle)
                .padding(.bottom, 50)

            Text("Hello, world!")

            Toggle("Show ImmersiveSpace", isOn: $showImmersiveSpace)
                .font(.title)
                .frame(width: 360)
                .padding(24)
                .glassBackgroundEffect()
        }
        .padding()
        .onChange(of: showImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    switch await openImmersiveSpace(id: "ImmersiveSpace") {
                    case .opened:
                        appState.isImmerseViewOpen = true
                    case .error, .userCancelled:
                        fallthrough
                    @unknown default:
                        appState.isImmerseViewOpen = false
                        showImmersiveSpace = false
                    }
                } else if appState.isImmerseViewOpen {
                    await dismissImmersiveSpace()
                    appState.isImmerseViewOpen = false
                }
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
