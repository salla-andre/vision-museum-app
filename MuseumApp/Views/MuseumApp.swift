//
//  MuseumApp.swift
//  MuseumApp
//
//  Created by André Salla on 10/06/24.
//

import SwiftUI

@main
@MainActor
struct MuseumApp: App {
    // Will persist and update states across the app
    @State private var appState = AppState()
    // ViewModel to provide business logic to the Immersive View
    @State private var model = MuseumViewModel()
    
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        .windowStyle(.plain)
        // Making the Window smaller so we just present the necessary interface
        // to enable/disable Immersive Space
        .defaultSize(width: 500, height: 150)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView(model: model)
        }
        .onChange(of: scenePhase, initial: true) {
            // If the scene becomes inactive, we dismiss the Immersive Space and
            // reset the app state so the user can interact with their local space
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
