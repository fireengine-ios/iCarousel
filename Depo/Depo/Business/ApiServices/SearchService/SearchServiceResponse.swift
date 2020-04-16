//
//  SearchServiceResponse.swift
//  Depo
//
//  Created by Alexander Gurin on 7/9/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import SwiftyJSON

struct SearchJsonKey {
    
    static let createdDate = "createdDate"
    static let lastModifiedDate = "lastModifiedDate"
    static let takenDate = "Image-DateTime"
    static let id = "id"
    static let hash = "hash"
    static let name = "name"
    static let uuid = "uuid"
    static let bytes = "bytes"
    static let content_type = "content_type"
    static let folder = "folder"
    static let status = "status"
    static let subordinates = "subordinates"
    static let uploaderDeviceType = "uploaderDeviceType"
    static let parent = "parent"
    static let tempDownloadURL = "tempDownloadURL"
    static let metadata = "metadata"
    static let album = "album"
    static let location = "location"
    static let foundItems = "found_items"
    static let foundItemsCount = "found_items_count"
    
    //Album
    static let albumName = "label"
    static let contentType = "contentType"
    static let contentTypeAlbum = "album/photo"
    
    
    //Favorite
    static let favourite = "X-Object-Meta-Favourite"
    static let fileList = "file-list"
    
    // metadata
    static let specialFolderMeta = "X-Object-Meta-Special-Folder"
    static let ThumbnailLarge = "Thumbnail-Large"
    static let ThumbnailSmall = "Thumbnail-Small"
    static let Thumbnail_Medium = "Thumbnail-Medium"
    static let ImageHeight = "Image-Height"
    static let ImageWidth = "Image-Width"
    static let ImageDateTime = "Image-DateTime"
    static let VideoPreview = "Video-Preview"
    static let DocumentPreview = "Document-Preview"
    
    // music metadata
    
    static let Artist = "Artist"
    static let Album = "Album"
    static let Title = "Title"
    static let Duration = "Duration"
    static let Genre = "Genre"
    
    // story metadata
    
    static let VideoSlideshow = "Video-Slideshow"
//    static let VideoHLSPreview = "Video-Hls-Preview"

    //folder
    static let ChildCount = "childCount"
    
    //face image
    static let objectList = "object_list"
    static let personList = "person_list"
    static let locationList = "location_list"
    static let personInfo = "personInfo"
    static let locationInfo = "locationInfo"
    static let objectInfo = "objectInfo"
}

//MARK:- BaseMetaData
final class BaseMetaData: ObjectRequestResponse, NSCoding {
    
    var favourite: Bool?
    var specialFolderMeta: String?
    
    // photo and video
    var height: Int = 0
    var width: Int = 0
    var takenDate: Date?
    var largeUrl: URL?
    var mediumUrl: URL?
    var smalURl: URL?
    var videoPreviewURL: URL?
    var documentPreviewURL: URL?
    
    // music
    var artist: String?
    
    var album: String?
    var title: String?
    var genre =  [String]()
    
    // music & video & story
    var duration: Double = Double(0.0)
    
    //story
    var isVideoSlideshow: Bool = false
//    var videoHLSPreview: URL?
    
    required init(withJSON: JSON?) {
        super.init(withJSON: withJSON)
    }
    
    required init(json: Data?, headerResponse: HTTPURLResponse?) {
        fatalError("init(json:headerResponse:) has not been implemented")
    }
    
    override init() {
        super.init()
    }
    
    override func mapping() {
        favourite = json?[SearchJsonKey.favourite].boolFromString ?? false
        specialFolderMeta = json?[SearchJsonKey.specialFolderMeta].string

        height = json?[SearchJsonKey.ImageHeight].int ?? 0
        width = json?[SearchJsonKey.ImageWidth].int ?? 0
        takenDate = json?[SearchJsonKey.ImageDateTime].date
        largeUrl = json?[SearchJsonKey.ThumbnailLarge].url
        mediumUrl = json?[SearchJsonKey.Thumbnail_Medium].url
        smalURl = json?[SearchJsonKey.ThumbnailSmall].url
        videoPreviewURL = json?[SearchJsonKey.VideoPreview].url
        documentPreviewURL = json?[SearchJsonKey.DocumentPreview].url
        
        artist = json?[SearchJsonKey.Artist].string
        album = json?[SearchJsonKey.Album].string
        title = json?[SearchJsonKey.Title].string
        
        if let durStr = json?[SearchJsonKey.Duration].stringValue, durStr.count > 0 {
            duration = Double( Double(durStr)! / 1000.0)
        }
        
        if let genreresponse = json?[SearchJsonKey.Genre].string {
            genre = genreresponse.components(separatedBy: ",")
        }
        
        if let slideshow = json?[SearchJsonKey.VideoSlideshow].string, !slideshow.isEmpty {
            isVideoSlideshow = slideshow == "true" ? true : false
        }
        
//        videoHLSPreview = json?[SearchJsonKey.VideoHLSPreview].url
    }
    
    //MARK:- BaseMetaData - Coding
    required init?(coder aDecoder: NSCoder) {
        super.init()
        favourite = aDecoder.decodeObject(forKey: SearchJsonKey.favourite) as? Bool
        height = aDecoder.decodeObject(forKey: SearchJsonKey.ImageHeight) as? Int ?? 0
        width = aDecoder.decodeObject(forKey:SearchJsonKey.ImageWidth) as? Int ?? 0
        takenDate = aDecoder.decodeObject(forKey: SearchJsonKey.ImageDateTime) as? Date
        largeUrl = aDecoder.decodeObject(forKey: SearchJsonKey.ThumbnailLarge) as? URL
        mediumUrl = aDecoder.decodeObject(forKey: SearchJsonKey.Thumbnail_Medium) as? URL
        smalURl = aDecoder.decodeObject(forKey: SearchJsonKey.ThumbnailSmall) as? URL
        videoPreviewURL = aDecoder.decodeObject(forKey: SearchJsonKey.VideoPreview) as? URL
        documentPreviewURL = aDecoder.decodeObject(forKey: SearchJsonKey.DocumentPreview) as? URL
        artist = aDecoder.decodeObject(forKey:SearchJsonKey.Artist) as? String
        album = aDecoder.decodeObject(forKey:SearchJsonKey.Album) as? String
        title = aDecoder.decodeObject(forKey:SearchJsonKey.Title) as? String
        duration = aDecoder.decodeObject(forKey:SearchJsonKey.Duration) as? Double ?? Double(0.0)
        genre = aDecoder.decodeObject(forKey:SearchJsonKey.Genre) as? [String] ?? []
        isVideoSlideshow = aDecoder.decodeObject(forKey: SearchJsonKey.VideoSlideshow) as? Bool ?? false
        specialFolderMeta = aDecoder.decodeObject(forKey: SearchJsonKey.specialFolderMeta) as? String
//        videoHLSPreview = aDecoder.decodeObject(forKey:SearchJsonKey.VideoHLSPreview) as? URL
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(favourite, forKey: SearchJsonKey.favourite)
        aCoder.encode(height, forKey: SearchJsonKey.ImageHeight)
        aCoder.encode(width, forKey: SearchJsonKey.ImageWidth)
        aCoder.encode(takenDate, forKey: SearchJsonKey.ImageDateTime)
        aCoder.encode(largeUrl, forKey: SearchJsonKey.ThumbnailLarge)
        aCoder.encode(mediumUrl, forKey: SearchJsonKey.Thumbnail_Medium)
        aCoder.encode(smalURl, forKey:  SearchJsonKey.ThumbnailSmall)
        aCoder.encode(videoPreviewURL, forKey: SearchJsonKey.VideoPreview)
        aCoder.encode(documentPreviewURL, forKey: SearchJsonKey.DocumentPreview)
        aCoder.encode(artist, forKey: SearchJsonKey.Artist)
        aCoder.encode(album, forKey: SearchJsonKey.Album)
        aCoder.encode(title, forKey: SearchJsonKey.Title)
        aCoder.encode(duration, forKey: SearchJsonKey.Duration)
        aCoder.encode(genre, forKey: SearchJsonKey.Genre)
        aCoder.encode(isVideoSlideshow, forKey: SearchJsonKey.VideoSlideshow)
        aCoder.encode(specialFolderMeta, forKey: SearchJsonKey.specialFolderMeta)
//        aCoder.encode(videoHLSPreview, forKey: SearchJsonKey.VideoHLSPreview)
    }
}

extension BaseMetaData {
    override func isEqual(_ object: Any?) -> Bool {
        guard let metaData = object as? BaseMetaData else {
            return false
        }

        return takenDate == metaData.takenDate &&
            largeUrl?.byTrimmingQuery == metaData.largeUrl?.byTrimmingQuery &&
            mediumUrl?.byTrimmingQuery == metaData.mediumUrl?.byTrimmingQuery &&
            smalURl?.byTrimmingQuery == metaData.smalURl?.byTrimmingQuery &&
            videoPreviewURL?.byTrimmingQuery == metaData.videoPreviewURL?.byTrimmingQuery &&
            documentPreviewURL?.byTrimmingQuery == metaData.documentPreviewURL?.byTrimmingQuery &&
            title == metaData.title &&
            duration.toInt() == metaData.duration.toInt() &&
            genre == metaData.genre &&
            artist == metaData.artist &&
//            videoHLSPreview?.byTrimmingQuery == metaData.videoHLSPreview?.byTrimmingQuery &&
            favourite == metaData.favourite &&
            height == metaData.height &&
            width == metaData.width &&
            isVideoSlideshow == metaData.isVideoSlideshow
    }
    
    func copy(metaData: BaseMetaData?) {
        guard let metaData = metaData else {
            return
        }
        
        takenDate = metaData.takenDate
        largeUrl = metaData.largeUrl
        mediumUrl = metaData.mediumUrl
        smalURl = metaData.smalURl
        videoPreviewURL = metaData.videoPreviewURL
        documentPreviewURL = metaData.documentPreviewURL
        title = metaData.title
        duration = metaData.duration
        genre = metaData.genre
        isVideoSlideshow = metaData.isVideoSlideshow
//        videoHLSPreview = metaData.videoHLSPreview
        favourite = metaData.favourite
        height = metaData.height
        width = metaData.width
    }
}


//MARK:- SearchItemResponse
final class SearchItemResponse: ObjectRequestResponse {
    
    var createdDate: Date?
    var lastModifiedDate: Date?
    var id: Int64?
    var itemHash: String?
    var name: String?
    var uuid: String?
    var bytes: Int64?
    var contentType: String?
    var folder: Bool?
    var status: String?
    var uploaderDeviceType: String?
    var parent: String?
    var tempDownloadURL: URL?
    var metadata: BaseMetaData?
    var albums: [String]?//Array<JSON>?
    var subordinates: Array<JSON>?
    var location: Any? // TODO Add!
    var childCount: Int64?
    
    override func mapping() {
        // it upload date
        createdDate = json?[SearchJsonKey.createdDate].date
        lastModifiedDate = json?[SearchJsonKey.lastModifiedDate].date
        id = json?[SearchJsonKey.id].int64
        itemHash = json?[SearchJsonKey.hash].string
        name = json?[SearchJsonKey.name].string
        uuid = json?[SearchJsonKey.uuid].string
        bytes = json?[SearchJsonKey.bytes].int64
        contentType = json?[SearchJsonKey.content_type].string
        metadata = BaseMetaData(withJSON: json?[SearchJsonKey.metadata])
        folder = json?[SearchJsonKey.folder].bool
        uploaderDeviceType = json?[SearchJsonKey.uploaderDeviceType].string
        parent = json?[SearchJsonKey.parent].string
        tempDownloadURL = json?[SearchJsonKey.tempDownloadURL].url
        status = json?[SearchJsonKey.status].string
        subordinates = json?[SearchJsonKey.subordinates].array
        albums = json?[SearchJsonKey.album].array?.compactMap { $0.string }
        childCount = json?[SearchJsonKey.ChildCount].int64
    }
}

extension SearchItemResponse {
    static func == (lhs: SearchItemResponse, rhs: SearchItemResponse) -> Bool {
        return lhs.uuid == rhs.uuid &&
            lhs.id == rhs.id &&
            lhs.name == rhs.name
    }
}

final class SearchResponse: ObjectRequestResponse {
    
    var list: Array<SearchItemResponse> = []
    
    override func mapping() {
        let  tmpList = json?.array
        if let result = tmpList?.compactMap({ SearchItemResponse(withJSON: $0) }) {
            list = result
        }
    }
}

struct FoundItemsInfoJsonKey {
    static let allFiles = "all_files"
    static let albums = "albums"
    static let documents = "documents"
    static let musics = "musics"
    static let photosAndVideos = "photos_and_videos"
}

final class FoundItemsInfoResponse: ObjectRequestResponse {
    var allFiles: Int64?
    var albums: Int64?
    var documents: Int64?
    var musics: Int64?
    var photosAndVideos: Int64?
    
    override func mapping() {
        allFiles = json?.dictionary?[FoundItemsInfoJsonKey.allFiles]?.int64
        albums = json?.dictionary?[FoundItemsInfoJsonKey.albums]?.int64
        documents = json?.dictionary?[FoundItemsInfoJsonKey.documents]?.int64
        musics = json?.dictionary?[FoundItemsInfoJsonKey.musics]?.int64
        photosAndVideos = json?.dictionary?[FoundItemsInfoJsonKey.photosAndVideos]?.int64
    }
}

final class UnifiedSearchResponse: ObjectRequestResponse {
    var itemsList = [SearchItemResponse]()
    var peopleList = [PeopleItemResponse]()
    var thingsList = [ThingsItemResponse]()
    var placesList = [PlacesItemResponse]()
    var info: FoundItemsInfoResponse?
    
    override func mapping() {
        if let foundItemsList = json?.dictionary?[SearchJsonKey.foundItems]?.array?.flatMap({ SearchItemResponse(withJSON: $0) }) {
            itemsList = foundItemsList
        }
        if let objectList = json?.dictionary?[SearchJsonKey.objectList]?.array?.flatMap({ ThingsItemResponse(withJSON: $0.dictionary?[SearchJsonKey.objectInfo]) }) {
            thingsList = objectList
        }
        if let personList = json?.dictionary?[SearchJsonKey.personList]?.array?.flatMap({ PeopleItemResponse(withJSON: $0.dictionary?[SearchJsonKey.personInfo]) }) {
            peopleList = personList
        }
        if let locationList = json?.dictionary?[SearchJsonKey.locationList]?.array?.flatMap({ PlacesItemResponse(withJSON: $0.dictionary?[SearchJsonKey.locationInfo]) }) {
            placesList = locationList
        }
        info = FoundItemsInfoResponse(withJSON: json?.dictionary?[SearchJsonKey.foundItemsCount])
    }
}

// MARK: - Suggestion

struct SuggestionJsonKey {
    
    static let type = "type"
    static let text = "text"
    static let highlightedText = "highlightedText"
    static let albumUuid = "albumUUID"
    
    //objectInfo
    static let id = "id"
    static let code = "code"
    static let name = "name"
    static let thumbnail = "thumbnail"
    static let ugglaId = "ugglaId"
    static let visible = "visible"
    static let adminLevel = "adminLevel"
}

enum SuggestionType: String {
    case time = "TIME"
    case place = "LOCATION"
    case category = "CATEGORY"
    case people = "PERSON"
    case thing = "OBJECT"
    
    var image: UIImage {
        switch self {
            case .time: return #imageLiteral(resourceName: "search_time")
            case .place: return #imageLiteral(resourceName: "search_places")
            case .category: return #imageLiteral(resourceName: "search_categories")
            case .people: return #imageLiteral(resourceName: "search_people")
            case .thing: return #imageLiteral(resourceName: "search_things")
        }
    }
    
    func isFaceImageType() -> Bool {
        return self == .people || self == .thing || self == .place
    }
}

final class SuggestionResponse: ObjectRequestResponse {
    var list: Array<SuggestionObject> = []
    
    override func mapping() {
        let tmpList = json?.array
        if let result = tmpList?.flatMap({ SuggestionObject(withJSON: $0) }) {
            list = result
        }
    }
}

final class SuggestionObject: ObjectRequestResponse {
    var text: String?
    var highlightedText: NSMutableAttributedString!
    var type: SuggestionType?
    var albumUuid: String?
    var info: SuggestionInfo?
    
    override func mapping() {
        text = json?[SuggestionJsonKey.text].string
        highlightedText = getHighlightedText(string: json?[SuggestionJsonKey.highlightedText].string)
        if let suggestionType = json?[SuggestionJsonKey.type].string {
            type = SuggestionType(rawValue: suggestionType)
            
            let infoKey = "\(suggestionType.lowercased())Info"
            info = SuggestionInfo(withJSON: json?[infoKey])
        }
        albumUuid = json?[SuggestionJsonKey.albumUuid].string
    }
    
    func getHighlightedText(string: String!) -> NSMutableAttributedString! {
        if let _ = string {
            var highlightedText = string! as NSString
            let r1 = highlightedText.range(of: "<m>")
            let r2 = highlightedText.range(of: "</m>")
            let rSub = NSMakeRange(r1.location + r1.length, r2.location - r1.location - r1.length)
            //            let rSub = Range(uncheckedBounds: (r1?.lowerBound + r1?.upperBound, r2?.lowerBound - r1?.lowerBound - r1?.upperBound))
            var sub = ""
            if rSub.location != NSNotFound {
                sub = highlightedText.substring(with: rSub)
                highlightedText = highlightedText.replacingOccurrences(of: "<m>", with: "") as NSString
                highlightedText = highlightedText.replacingOccurrences(of: "</m>", with: "") as NSString
            }
            let attributedString = NSMutableAttributedString(string: highlightedText as String)
            attributedString.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.white], range: NSMakeRange(0, highlightedText.length))
            attributedString.addAttributes([NSAttributedStringKey.foregroundColor : ColorConstants.blueColor], range: highlightedText.range(of: sub))
            attributedString.addAttributes([NSAttributedStringKey.font : UIFont.TurkcellSaturaDemFont(size: 15)], range: NSMakeRange(0, highlightedText.length))
            return attributedString
        }
        return nil
    }
}

final class SuggestionInfo: ObjectRequestResponse {
    var id: Int64?
    var code: String?
    var name: String?
    var thumbnail: URL?
    var ugglaId: Int64?
    var visible: Bool?
    var adminLevel: String?
    
    override func mapping() {
        id = json?[SuggestionJsonKey.id].int64
        code = json?[SuggestionJsonKey.code].string
        name = json?[SuggestionJsonKey.name].string
        thumbnail = json?[SuggestionJsonKey.thumbnail].url
    }
}
