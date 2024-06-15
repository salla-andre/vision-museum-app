//
//  MuseumAppApp.swift
//  MuseumApp
//
//  Created by André Salla on 10/06/24.
//

import SwiftUI

@main
@MainActor
struct MuseumAppApp: App {
    @State private var appState = AppState()
    
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        .windowStyle(.plain)
        .defaultSize(width: 500, height: 150)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView(model: MuseumViewModel())
        }
        .onChange(of: scenePhase, initial: true) {
            if scenePhase != .active && appState.isImmerseViewOpen {
                Task {
                    await dismissImmersiveSpace()
                    appState.isImmerseViewOpen = false
                    appState.isImmerseToggleOn = false
                }
            }
        }
    }
}
