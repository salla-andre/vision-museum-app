//
//  Attachments.swift
//  MuseumApp
//
//  Created by André Salla on 13/06/24.
//

import Foundation

enum Attachments: CaseIterable, Hashable {
    case infoButtonShow(item: Items)
    case infoButtonHide(item: Items)
    case infoView(item: Items)
    
    static let allCases: [Attachments] = Items.allCases.flatMap { [
        .infoView(item: $0),
        .infoButtonHide(item: $0),
        .infoButtonShow(item: $0)
    ] }
    
    var opposite: Self? {
        switch self {
            case .infoButtonShow(let item): .infoButtonHide(item: item)
            case .infoButtonHide(let item): .infoButtonShow(item: item)
            case .infoView(_): nil
        }
    }
    
    var item: Items {
        switch self {
            case .infoButtonShow(let item): item
            case .infoButtonHide(let item): item
            case .infoView(let item): item
        }
    }
    
    var isShow: Bool {
        switch self {
            case .infoButtonShow(_): true
            default: false
        }
    }
}
