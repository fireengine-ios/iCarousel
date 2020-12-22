//
//  BecomePremiumViewSourceType.swift
//  Depo
//
//  Created by Andrei Novikau on 3/4/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

enum BecomePremiumViewSourceType {
    case people
    case places
    case things
    case contactSync
    case `default`
}

extension BecomePremiumViewSourceType {
    var title: String {
        switch self {
        case .people:
            return TextConstants.becomePremiumHeaderPeopleTitle
        case .places:
            return TextConstants.becomePremiumHeaderPlacesTitle
        case .things:
            return TextConstants.becomePremiumHeaderThingsTitle
        case .contactSync:
            return TextConstants.becomePremiumHeaderContactSyncTitle
        default:
            return TextConstants.becomePremiumHeaderDefaultTitle
        }
    }
    
    var subtitle: String {
        switch self {
        case .people:
            return TextConstants.becomePremiumHeaderPeopleSubtitle
        case .places:
            return TextConstants.becomePremiumHeaderPlacesSubtitle
        case .things:
            return TextConstants.becomePremiumHeaderThingsSubtitle
            case .contactSync:
            return TextConstants.becomePremiumHeaderContactSyncSubtitle
        default:
            return TextConstants.becomePremiumHeaderDefaultSubtitle
        }
    }
}
