//
//  ForYouViewEnum.swift
//  Depo
//
//  Created by Burak Donat on 2.08.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

enum ForYouSections: CaseIterable {
    case faceImage
    case people
    case collageCards
    case collages
    case animationCards
    case animations
    case albumCards
    case albums
    case places
    case story
    case photopick
    case things
    case hidden
    
    var title: String {
        switch self {
        case .faceImage: return ""
        case .people: return TextConstants.myStreamPeopleTitle
        case .things: return TextConstants.myStreamThingsTitle
        case .places: return TextConstants.myStreamPlacesTitle
        case .albums: return "My Albums"
        case .photopick: return TextConstants.myStreamInstaPickTitle
        case .story: return TextConstants.myStreamStoriesTitle
        case .animations: return "My Animations"
        case .collageCards: return "Collages"
        case .collages: return "My Collages"
        case .hidden: return TextConstants.smartAlbumHidden
        case .animationCards: return "Animations"
        case .albumCards: return TextConstants.myStreamAlbumsTitle
        }
    }
    
    var emptyText: String {
        switch self {
        case .albums:
            return "You don't have any album"
        case .photopick:
            return "You don't have any photopick"
        case .story:
            return "You don't have any story"
        default:
            return ""
        }
    }
    
    var buttonText: String {
        switch self {
        case .albums:
            return TextConstants.createAlbum
        case .photopick:
            return "Photopick'i dene"
        case .story:
            return TextConstants.createStory
        default:
            return ""
        }
    }
}
