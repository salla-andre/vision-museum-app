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
    @State private var model = MuseumViewModel()
    @State private var appState = AppState()
    
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .environment(model)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        .onChange(of: scenePhase, initial: true) {
            if scenePhase != .active && appState.isImmerseViewOpen {
                Task {
                    appState.isImmerseViewOpen = false
                    await dismissImmersiveSpace()
                    model = MuseumViewModel()
                }
            }
        }
    }
}
