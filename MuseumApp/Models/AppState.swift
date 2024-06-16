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
    var isImmerseViewOpen: Bool = false
    var isImmerseToggleOn: Bool = false
    var providersStoppedWithError: Bool = false    
}
