//
//  ForYouViewEnum.swift
//  Depo
//
//  Created by Burak Donat on 2.08.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

enum ForYouSections: CaseIterable {
    /// this enum is sorted in the same order as the For You  screen.
    case faceImage
    case people
    case throwback
    case collageCards
    case collages
    case animationCards
    case animations
    case albumCards
    case albums
    case favorites
    case places
    case story
    case photopick
    case things
    case hidden
    
    var title: String {
        switch self {
        case .faceImage: return ""
        case .throwback: return localized(.forYouThrowbackTitle)
        case .people: return TextConstants.myStreamPeopleTitle
        case .things: return TextConstants.myStreamThingsTitle
        case .places: return TextConstants.myStreamPlacesTitle
        case .albums: return localized(.forYouMyAlbumsTitle)
        case .favorites: return TextConstants.containerFavourite
        case .photopick: return TextConstants.myStreamInstaPickTitle
        case .story: return TextConstants.myStreamStoriesTitle
        case .animations: return localized(.forYouMyAnimationsTitle)
        case .collageCards: return localized(.forYouCollagesTitle)
        case .collages: return localized(.forYouMyCollagesTitle)
        case .hidden: return TextConstants.smartAlbumHidden
        case .animationCards: return localized(.forYouAnimationsTitle)
        case .albumCards: return TextConstants.myStreamAlbumsTitle
        }
    }
    
    var emptyText: String {
        switch self {
        case .albums:
            return localized(.forYouEmptyAlbumsDesc)
        case .photopick:
            return localized(.forYouEmptyPhotopickDesc)
        case .story:
            return localized(.forYouEmptyStoryDesc)
        default:
            return ""
        }
    }
    
    var buttonText: String {
        switch self {
        case .albums:
            return TextConstants.createAlbum
        case .photopick:
            return localized(.forYouEmptyPhotopickButton)
        case .story:
            return TextConstants.createStory
        default:
            return ""
        }
    }
}
