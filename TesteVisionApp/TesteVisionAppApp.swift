//
//  TesteVisionAppApp.swift
//  TesteVisionApp
//
//  Created by André Salla on 10/06/24.
//

import SwiftUI

@main
struct TesteVisionAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }.immersionStyle(selection: .constant(.full), in: .full)
    }
}
