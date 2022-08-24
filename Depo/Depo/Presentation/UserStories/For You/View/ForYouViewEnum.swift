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
    case things
    case places
    case albums
    case photopick
//    case throwback
//    case collage
    
    var title: String {
        switch self {
        case .faceImage: return ""
        case .people: return "People"
        case .things: return "Things"
        case .places: return "Places"
        case .albums: return "Albums"
        case .photopick: return "Photopick"
        //        case .throwback: return "Throwback"
        //        case .collage: return "Collage"
        }
    }
    
    var emptyText: String {
        switch self {
        case .faceImage:
            return ""
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
