//
//  LBAlbumLikePreviewSliderDataStorage.swift
//  Depo
//
//  Created by Aleksandr on 8/21/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

enum MyStreamType: Int {
    case instaPick = 0
    case people
    case things
    case places
    case story
    case albums
    case album
    case firAlbum
    case hidden
    
    var title: String {
        switch self {
        case .instaPick: return TextConstants.myStreamInstaPickTitle
        case .albums: return TextConstants.myStreamAlbumsTitle
        case .story: return TextConstants.myStreamStoriesTitle
        case .people: return TextConstants.myStreamPeopleTitle
        case .things: return TextConstants.myStreamThingsTitle
        case .places: return TextConstants.myStreamPlacesTitle
        case .hidden: return TextConstants.smartAlbumHidden
        default: return ""
        }
    }
    
    var placeholder: UIImage {
        switch self {
        case .instaPick: return #imageLiteral(resourceName: "tryInstapick")
        case .albums: return #imageLiteral(resourceName: "album")
        case .story: return #imageLiteral(resourceName: "story")
        case .people: return #imageLiteral(resourceName: "people")
        case .things: return #imageLiteral(resourceName: "things")
        case .places: return #imageLiteral(resourceName: "places")
        case .firAlbum: return #imageLiteral(resourceName: "places")
        case .hidden: return #imageLiteral(resourceName: "places")
        default: return UIImage()
        }
    }
    
    var placeholderBorderColor: CGColor {
        switch self {
        case .instaPick:
            return UIColor.white.cgColor
        default:
            return ColorConstants.blueColor.cgColor
        }
    }
    
    func isMyStreamSliderType() -> Bool {
        switch self {
        case .albums, .story, .people, .things, .places, .instaPick, .hidden:
            return true
        case .album, .firAlbum:
            return false
        }
    }
    
    func isFaceImageType() -> Bool {
        return self.isContained(in: [.people, .things, .places])
    }
}

class SliderItem {
    var name: String?
    var previewItems: [PathForItem]?
    var previewPlaceholders = [UIImage?]()
    var type: MyStreamType? {
        didSet {
            placeholderImage = type?.placeholder
            name = type?.title
            if type == .instaPick {
                previewPlaceholders = [UIImage(named: "dummyInstaPickThumbnail_2"),
                                      UIImage(named: "dummyInstaPickThumbnail_0"),
                                      UIImage(named: "dummyInstaPickThumbnail_1"),
                                      UIImage(named: "dummyInstaPickThumbnail_2")]
                
            }
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
            previewItems = Array(items.prefix(NumericConstants.myStreamSliderThumbnailsCount).flatMap { $0.preview?.patchToPreview })
        }
        setType(.albums)
    }
    
    init(withStoriesItems items: [Item]?) {
        if let items = items {
            previewItems = Array(items.prefix(NumericConstants.myStreamSliderThumbnailsCount).flatMap { $0.patchToPreview })
        }
        setType(.story)
    }
    
    init(withAlbum album: AlbumItem) {
        setType(.album)
        name = album.name
        previewItems = [PathForItem.remoteUrl(album.preview?.tmpDownloadUrl)]
        albumItem = album
    }
    
    convenience init(asFirAlbum album: AlbumItem) {
        self.init(withAlbum: album)
        setType(.firAlbum)
        name = album.name
    }
    
    init(withThumbnails items: [URL?], type: MyStreamType) {
        previewItems = items.flatMap { PathForItem.remoteUrl($0) }
        setType(type)
    }
    
    private func setType(_ type: MyStreamType?) {
        self.type = type
    }
}

extension SliderItem: Equatable {
    static func == (lhs: SliderItem, rhs: SliderItem) -> Bool {
        return lhs.type == rhs.type && lhs.albumItem == rhs.albumItem
    }
}

final class SmartAlbumsDataStorage {
    
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
