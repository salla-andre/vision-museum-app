//
//  InfoViewModel.swift
//  MuseumApp
//
//  Created by André Salla on 14/06/24.
//

import Foundation

@MainActor
@Observable
class InfoViewModel {
    private(set) var title: String
    private(set) var description: String
    var item: Items {
        didSet {
            title = item.title
            description = item.description
        }
    }
    
    init(item: Items) {
        self.item = item
        self.title = item.title
        self.description = item.description
    }
}
