//
//  AppState.swift
//  MuseumApp
//
//  Created by André Salla on 15/06/24.
//

import Foundation

@MainActor
@Observable
class AppState {
    var isImmerseViewOpen: Bool
    var isImmerseToggleOn: Bool
    
    init(isImmerseViewOpen: Bool = false, isImmerseToggleOn: Bool = false) {
        self.isImmerseViewOpen = isImmerseViewOpen
        self.isImmerseToggleOn = isImmerseToggleOn
    }
}
