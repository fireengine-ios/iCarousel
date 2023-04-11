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
        case .dual: return localized(.createCollageDualCollage)
        case .triple: return localized(.createCollageTripleCollage)
        case .quad: return localized(.createCollageQuadCollage)
        case .multiple: return localized(.createCollageMultipleCollage)
        case .all: return localized(.createCollageAllCollage)
        }
    }
    
    var seeAllTitle: String {
        switch self {
        case .dual: return localized(.forYouSeeAll)
        case .triple: return localized(.forYouSeeAll)
        case .quad: return localized(.forYouSeeAll)
        case .multiple: return localized(.forYouSeeAll)
        case .all: return localized(.forYouSeeAll)
        }
    }
    
}
