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
        case .album: return "Albums"
        case .story: return "Stories"
        case .people: return "People"
        case .things: return "Things"
        case .places: return "Places"
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
