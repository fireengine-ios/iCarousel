//
//  Spotlight.swift
//  Depo
//
//  Created by Andrei Novikau on 20/04/2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

enum SpotlightType: Int {
    case homePageIcon = 1
    case homePageGeneral
    case movieCard
    case albumCard
    case collageCard
    case animationCard
    case filterCard
    
    var title: String {
        switch self {
        case .homePageIcon: return TextConstants.spotlightHomePageIconText
        case .homePageGeneral: return TextConstants.spotlightHomePageGeneralText
        case .movieCard: return TextConstants.spotlightMovieCardText
        case .albumCard: return TextConstants.spotlightAlbumCard
        case .collageCard: return TextConstants.spotlightCollageCard
        case .animationCard: return TextConstants.spotlightAnimationCard
        case .filterCard: return TextConstants.spotlightFilterCard
        }
    }
    
    var cellType: BaseView.Type {
        return ContactBackupOld.self
        switch self {
        case .movieCard: return MovieCard.self
        case .albumCard: return AlbumCard.self
        case .collageCard: return CollageCard.self
        case .animationCard: return AnimationCard.self
        case .filterCard: return FilterPhotoCard.self
        default: return BaseView.self
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

    private var lastShownSpotlight: Int {
        get { return UserDefaults.standard.integer(forKey: "lastShownSpotlight") }
        set { UserDefaults.standard.set(newValue, forKey: "lastShownSpotlight")}
    }
    
    func requestShowSpotlight() {
        if lastShownSpotlight < SpotlightType.filterCard.rawValue, let spotlight = SpotlightType(rawValue: lastShownSpotlight + 1) {
            delegate?.needShowSpotlight(type: spotlight)
        }
    }
    
    func shownSpotlight(type: SpotlightType) {
        lastShownSpotlight = type.rawValue
    }
    
    
}
