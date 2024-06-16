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
    @State private var appState = AppState()
    @State private var model = MuseumViewModel()
    
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
            ImmersiveView(model: model)
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
