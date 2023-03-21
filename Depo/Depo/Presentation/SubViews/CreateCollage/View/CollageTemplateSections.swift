//
//  CollageTemplateSections.swift
//  Depo
//
//  Created by Ozan Salman on 4.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

enum CollageTemplateSections: CaseIterable {
    /// this enum is sorted in the same order as the For You  screen.
    case dual
    case triple
    case quad
    case multiple
    case all
    
    var title: String {
        switch self {
        case .dual: return "ikili Kolaj"
        case .triple: return "üçlü Kolaj"
        case .quad: return "dörtlü Kolaj"
        case .multiple: return "çoklu Kolaj"
        case .all: return "Tümü"
        }
    }
    
    var seeAllTitle: String {
        switch self {
        case .dual: return "See All 2"
        case .triple: return "See All 3"
        case .quad: return "See All 4"
        case .multiple: return "See All 5"
        case .all: return "See All"
        }
    }
    
}
