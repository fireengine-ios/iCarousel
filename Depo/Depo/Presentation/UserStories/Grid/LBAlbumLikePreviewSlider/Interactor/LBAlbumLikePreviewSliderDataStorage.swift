//
//  LBAlbumLikePreviewSliderDataStorage.swift
//  Depo
//
//  Created by Aleksandr on 8/21/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

enum MyStreamType: Int {
    case album
    case story
    case people
    case things
    case places
    
    var title: String {
        switch self {
        case .album: return TextConstants.myStreamAlbumsTitle
        case .story: return TextConstants.myStreamStoriesTitle
        case .people: return TextConstants.myStreamPeopleTitle
        case .things: return TextConstants.myStreamThingsTitle
        case .places: return TextConstants.myStreamPlacesTitle
        }
    }
}

class LBAlbumLikePreviewSliderDataStorage {
    var albumItems: [AlbumItem] = []
    var storyItems: [Item] = []
    var peopleItems: [Item] = []
    var thingItems: [Item] = []
    var placeItems: [Item] = []
}
