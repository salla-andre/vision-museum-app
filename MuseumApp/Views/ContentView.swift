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
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(AppState.self) var appState

    var body: some View {
        @Bindable var appState = appState
        VStack {
            Toggle("Open the Museum View", systemImage: "mountain.2", isOn: $appState.isImmerseToggleOn)
                .tint(.infoText)
                .font(.headline)
                .fontWeight(.black)
                .frame(width: 360)
                .padding(36)
                .glassBackgroundEffect()
        }
        .padding()
        .onChange(of: appState.isImmerseToggleOn) { _, newValue in
            Task {
                if newValue {
                    switch await openImmersiveSpace(id: "ImmersiveSpace") {
                    case .opened:
                        appState.isImmerseViewOpen = true
                    case .error, .userCancelled:
                        fallthrough
                    @unknown default:
                        appState.isImmerseViewOpen = false
                        appState.isImmerseToggleOn = false
                    }
                } else if appState.isImmerseViewOpen {
                    await dismissImmersiveSpace()
                    appState.isImmerseViewOpen = false
                }
            }
        }
        .task {
            // Asking authorization before opening the ImmersiveSpace
            // so we may provide a better experience if it fails or
            // if the user denies access.
            await ARSessionManager.requestAuthorization()
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppState())
}
