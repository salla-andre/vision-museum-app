//
//  Attachments.swift
//  MuseumApp
//
//  Created by André Salla on 13/06/24.
//

import Foundation

enum Attachments: CaseIterable, Hashable {
    case infoButtonShow
    case infoButtonHide
    case infoView(item: Items)
    
    static var allCases: [Attachments] =
    [
        .infoButtonShow,
        .infoButtonHide,
    ] + Items.allCases.map { .infoView(item: $0) }
}
