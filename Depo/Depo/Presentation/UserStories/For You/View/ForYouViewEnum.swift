//
//  ForYouViewEnum.swift
//  Depo
//
//  Created by Burak Donat on 2.08.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

enum ForYouViewEnum: CaseIterable {
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
        case .people: return "People"
        case .things: return "Things"
        case .places: return "Places"
        case .albums: return "My Albums"
        case .photopick: return "Photopick"
        case .story: return "My Stories"
        case .animations: return "My Animations"
        case .collageCards: return "Collages"
        case .collages: return "My Collages"
        case .hidden: return "Hidden"
        case .animationCards: return "Animations"
        case .albumCards: return "Albums"
        }
    }
    
    var emptyText: String {
        switch self {
        case .people:
            return "You don't have any people"
        case .things:
            return "You don't have any thing"
        case .places:
            return "You don't have any place"
        case .albums:
            return "You don't have any album"
        case .photopick:
            return "You don't have any photopick"
        default:
            return ""
        }
    }
    
    var buttonText: String {
        switch self {
        case .albums:
            return "Bir albüm oluştur"
        case .photopick:
            return "Photopick'i dene"
        default:
            return ""
        }
    }
}
