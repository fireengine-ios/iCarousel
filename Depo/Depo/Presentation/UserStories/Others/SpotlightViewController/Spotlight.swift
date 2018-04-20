//
//  Spotlight.swift
//  Depo
//
//  Created by Andrei Novikau on 20/04/2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

enum SpotlightType {
    case homePageIcon
    case homePageGeneral
    case movieCard
    case albumCard
    case collageCard
    case animationCard
    case filterCard
    
    var title: String {
        switch self {
        case .homePageIcon: return ""
        case .homePageGeneral: return ""
        case .movieCard: return ""
        case .albumCard: return ""
        case .collageCard: return ""
        case .animationCard: return ""
        case .filterCard: return ""
        }
    }
}

protocol SpotlightManagerDelegate: class {
    func needShowSpotlight(type: SpotlightType)
}

final class SpotlightManager {
    
    private init() { }
    
    static let shared = SpotlightManager()
    
    weak var delegate: SpotlightManagerDelegate?
    
    func requestShowSpotlight() {
        
    }
    
    func shownSpotlight(type: SpotlightType) {
        
    }
    
    
}
