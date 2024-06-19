//
//  InfoModel.swift
//  MuseumApp
//
//  Created by André Salla on 14/06/24.
//

import Foundation

struct InfoModel {
    let title: String
    let description: String
    var state: InfoViewState = .hide
    
    init(item: Items) {
        self.title = item.title
        self.description = item.description
    }
}
