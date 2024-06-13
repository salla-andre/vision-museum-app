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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .environment(model)
        }.immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
