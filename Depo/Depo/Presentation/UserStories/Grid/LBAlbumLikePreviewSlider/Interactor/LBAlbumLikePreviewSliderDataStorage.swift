//
//  LBAlbumLikePreviewSliderDataStorage.swift
//  Depo
//
//  Created by Aleksandr on 8/21/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

enum MyStreamType: Int {
    case people = 0
    case things
    case places
    case story
    case albums
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
        case .albums: return #imageLiteral(resourceName: "album")
        case .story: return #imageLiteral(resourceName: "story")
        case .people: return #imageLiteral(resourceName: "people")
        case .things: return #imageLiteral(resourceName: "things")
        case .places: return #imageLiteral(resourceName: "places")
        default: return UIImage()
        }
    }
    
    var placeholderBorderColor: CGColor {
        switch self {
        case .albums, .album, .story:
            return ColorConstants.blueColor.cgColor
        case .things, .places, .people:
            return ColorConstants.orangeBorder.cgColor
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
    
    func isFaceImageType() -> Bool {
        return self == .people || self == .things || self == .places
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
    
    init(name: String?, previewItems: [PathForItem]?, placeholder: UIImage?, type: MyStreamType?) {
        self.type = type
        self.name = name
        self.previewItems = previewItems
        self.placeholderImage = placeholder
    }
    
    init(withAlbumItems items: [AlbumItem]?) {
        if let items = items {
            previewItems = Array(items.prefix(NumericConstants.myStreamSliderThumbnailsCount).compactMap { $0.preview?.patchToPreview })
        }
        setType(.albums)
    }
    
    init(withStoriesItems items: [Item]?) {
        if let items = items {
            previewItems = Array(items.prefix(NumericConstants.myStreamSliderThumbnailsCount).compactMap { $0.patchToPreview })
        }
        setType(.story)
    }
    
    init(withAlbum album: AlbumItem) {
        setType(.album)
        name = album.name
        previewItems = [PathForItem.remoteUrl(album.preview?.tmpDownloadUrl)]
        albumItem = album
    }
    
    init(withThumbnails items: [URL?], type: MyStreamType) {
        previewItems = items.compactMap { PathForItem.remoteUrl($0) }
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
           let index = currentItems.index(where: { $0.type == item.type }) {
            currentItems[index] = item
        } else {
            currentItems.append(item)
        }
    }
}
