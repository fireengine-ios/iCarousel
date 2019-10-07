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
    case homePageGeneral = 2
    case movieCard = 3
    case albumCard = 4
    case collageCard = 5
//    case animationCard = 6
    case filterCard = 7
    
    var title: String {
        switch self {
        case .homePageIcon: return TextConstants.spotlightHomePageIconText
        case .homePageGeneral: return TextConstants.spotlightHomePageGeneralText
        case .movieCard: return TextConstants.spotlightMovieCardText
        case .albumCard: return TextConstants.spotlightAlbumCard
        case .collageCard: return TextConstants.spotlightCollageCard
//        case .animationCard: return TextConstants.spotlightAnimationCard
        case .filterCard: return TextConstants.spotlightFilterCard
        }
    }
    
    var cellType: BaseView.Type {
        switch self {
        case .movieCard: return MovieCard.self
        case .albumCard: return AlbumCard.self
        case .collageCard: return CollageCard.self
//        case .animationCard: return AnimationCard.self
        case .filterCard: return FilterPhotoCard.self
        default: return BaseView.self
        }
    }
    
    init?(cardView: BaseView) {
        if cardView is MovieCard {
            self = .movieCard
        } else if cardView is AlbumCard {
            self = .albumCard
        } else if cardView is CollageCard {
            self = .collageCard
//        } else if cardView is AnimationCard {
//            self = .animationCard
        } else if cardView is FilterPhotoCard {
            self = .filterCard
        } else {
            return nil
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
    
    private lazy var storageVars: StorageVars = factory.resolve()

    private let shownSpotlightsKey = "shownSpotlightsByUserID"
    private var shownSpotlights: [Int] {
        get {
            let userId = SingletonStorage.shared.uniqueUserID
            guard let dict = UserDefaults.standard.dictionary(forKey: shownSpotlightsKey) as? [String: [Int]] else {
                return []
            }
            return dict[userId] ?? []
        }
        set {
            let userId = SingletonStorage.shared.uniqueUserID
            var dict = UserDefaults.standard.dictionary(forKey: shownSpotlightsKey) as? [String: [Int]] ?? [String: [Int]]()
            dict[userId] = newValue
            
            UserDefaults.standard.set(dict, forKey: shownSpotlightsKey)
            UserDefaults.standard.synchronize()
        }
        
    }
    
    func clear() {
        shownSpotlights = [Int]()
    }
    
    func requestShowSpotlight(for types: [SpotlightType]) {
        let canShowTypes = Set(types.map { $0.rawValue })
        if let needShowTypeRaw = canShowTypes.subtracting(Set(shownSpotlights)).min(),
            let needShowType = SpotlightType(rawValue: needShowTypeRaw) {
            delegate?.needShowSpotlight(type: needShowType)
        }
    }
    
    func shownSpotlight(type: SpotlightType) {
        if !shownSpotlights.contains(type.rawValue) {
            shownSpotlights.append(type.rawValue)
        }
    }
    
    func closedSpotlight(type: SpotlightType) {
        if type == .homePageIcon {
            delegate?.needShowSpotlight(type: .homePageGeneral)
        }
    }
    
}
