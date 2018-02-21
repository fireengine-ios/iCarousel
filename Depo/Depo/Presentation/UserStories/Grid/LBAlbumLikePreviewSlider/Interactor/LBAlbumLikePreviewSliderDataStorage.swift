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
    
    var placeholder: UIImage {
        switch self {
        case .albums: return UIImage()
        case .story: return UIImage()
        case .people: return #imageLiteral(resourceName: "people")
        case .things: return #imageLiteral(resourceName: "things")
        case .places: return #imageLiteral(resourceName: "places")
        default: return UIImage()
        }
    }
    
    func isMyStreamSliderType() -> Bool {
        switch self {
        case .albums, .story, .people, .things, .places:
            return true
        case .album:
            return false
        }
    }
}

class SliderItem {
    var name: String?
    var previewItems: [PathForItem]?
    var type: MyStreamType? {
        didSet {
            placeholderImage = type?.placeholder
            name = type?.title
        }
    }
    var placeholderImage: UIImage?
    var albumItem: AlbumItem?
    
    init(name: String?, previewItems:[PathForItem]?, placeholder: UIImage?, type: MyStreamType?) {
        self.type = type
        self.name = name
        self.previewItems = previewItems
        self.placeholderImage = placeholder
    }
    
    init(withAlbumItems items: [AlbumItem]?) {
        if let items = items {
            previewItems = Array(items.prefix(4).flatMap {$0.preview?.patchToPreview})
        }
        setType(.albums)
    }
    
    init(withStoriesItems items: [Item]?) {
        if let items = items {
            previewItems = Array(items.prefix(4).flatMap {$0.patchToPreview})
        }
        setType(.story)
    }
    
    init(withAlbum album: AlbumItem) {
        setType(.album)
        name = album.name
        previewItems = [PathForItem.remoteUrl(album.preview?.tmpDownloadUrl)]
        albumItem = album
    }
    
    init(withThumbnails items:[URL?], type: MyStreamType) {
        previewItems = items.flatMap { PathForItem.remoteUrl($0) }
        setType(type)
    }
    
    private func setType(_ type: MyStreamType?) {
        self.type = type
    }
}

class LBAlbumLikePreviewSliderDataStorage {
    
    var storyItems: [Item] = []
    var currentItems: [SliderItem] = []
    
    func addNew(item: SliderItem) {
        if let type = item.type, type.isMyStreamSliderType(),
           let index = currentItems.index(where: {$0.type == item.type}) {
            currentItems[index] = item
        } else {
            currentItems.append(item)
        }
    }
}
