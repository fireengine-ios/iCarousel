//
//  LBAlbumLikePreviewSliderDataStorage.swift
//  Depo
//
//  Created by Aleksandr on 8/21/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

enum MyStreamType: Int {
    case albums = 0
    case story
    case people
    case things
    case places
    case album
    
    var title: String {
        switch self {
        case .albums: return TextConstants.myStreamAlbumsTitle
        case .story: return TextConstants.myStreamStoriesTitle
        case .people: return TextConstants.myStreamPeopleTitle
        case .things: return TextConstants.myStreamThingsTitle
        case .places: return TextConstants.myStreamPlacesTitle
        default: return ""
        }
    }
}

class SliderItem {
    var name: String?
    var previewItems: [PathForItem]?
    var placeholderImage: UIImage?
    var type: MyStreamType?
    var albumItem: AlbumItem?
    
    init(name: String?, previewItems:[PathForItem]?, placeholder: UIImage?, type: MyStreamType?) {
        self.name = name
        self.previewItems = previewItems
        self.placeholderImage = placeholder
        self.type = type
    }
    
    init(withAlbumItems items: [AlbumItem]?) {
        name = TextConstants.myStreamAlbumsTitle
        if let items = items {
            previewItems = Array(items.prefix(4).flatMap {$0.preview?.patchToPreview})
        }
        type = .albums
        placeholderImage = UIImage() //TODO: No image
    }
    
    init(withStoriesItems items: [Item]?) {
        name = TextConstants.myStreamStoriesTitle
        if let items = items {
            previewItems = Array(items.prefix(4).flatMap {$0.patchToPreview})
        }
        type = .story
        placeholderImage = UIImage() //TODO: No image
    }
    
    init(withPeopleItems items: [PeopleItemResponse]?) {
        name = TextConstants.myStreamPeopleTitle
        if let items = items {
            previewItems = Array(items.prefix(4).flatMap {PathForItem.remoteUrl($0.thumbnail)})
        }
        type = .people
        placeholderImage = #imageLiteral(resourceName: "people")
    }
    
    init(withThingItems items: [ThingsItemResponse]?) {
        name = TextConstants.myStreamThingsTitle
        if let items = items {
            previewItems = Array(items.prefix(4).flatMap {PathForItem.remoteUrl($0.thumbnail)})
        }
        type = .things
        placeholderImage = #imageLiteral(resourceName: "things")
    }
    
    init(withPlaceItems items: [PlacesItemResponse]?) {
        name = TextConstants.myStreamPlacesTitle
        if let items = items {
            previewItems = Array(items.prefix(4).flatMap {PathForItem.remoteUrl($0.thumbnail)})
        }
        type = .places
        placeholderImage = #imageLiteral(resourceName: "places")
    }
    
    init(withAlbum album: AlbumItem) {
        name = album.name
        type = .album
        previewItems = [PathForItem.remoteUrl(album.preview?.tmpDownloadUrl)]
        albumItem = album
    }
}

class LBAlbumLikePreviewSliderDataStorage {
    
    var storyItems: [Item] = []
    var currentItems: [SliderItem] = []
    
    func addNew(item: SliderItem) {
        currentItems.append(item)
    }
}
