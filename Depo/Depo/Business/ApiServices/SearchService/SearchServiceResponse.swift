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
    
    //Album
    static let albumName = "label"
    static let contentType = "contentType"
    static let contentTypeAlbum = "album/photo"
    
    
    //Favorite
    static let favourite = "X-Object-Meta-Favourite"
    static let fileList = "file-list"
    
    // metadata
    
    static let ThumbnailLarge = "Thumbnail-Large"
    static let ThumbnailSmall = "Thumbnail-Small"
    static let Thumbnail_Medium = "Thumbnail-Medium"
    static let ImageHeight = "Image-Height"
    static let ImageWidth = "Image-Width"
    static let ImageDateTime = "Image-DateTime"
    static let VideoPreview = "Video-Preview"
    
    // music metadata
    
    static let Artist = "Artist"
    static let Album = "Album"
    static let Title = "Title"
    static let Duration = "Duration"
    static let Genre = "Genre"
    
    // story metadata
    
    static let VideoSlideshow = "Video-Slideshow"
    static let VideoHLSPreview = "Video-Hls-Preview"

    //folder
    static let ChildCount = "childCount"
}

class BaseMetaData: ObjectRequestResponse {
    
    var favourite: Bool?
    
    // photo and video
    var height: Int16?
    var width: Int16?
    var takenDate: Date?
    var largeUrl: URL?
    var mediumUrl: URL?
    var smalURl: URL?
    var videoPreviewURL: URL?
    
    // music
    var artist: String?
    
    var album: String?
    var title: String?
    var genre =  [String]()
    
    // music & video & story
    var duration: Double?
    
    //story
    var videoSlideshow: Bool?
    var videoHLSPreview: URL?
    
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
        
        height = json?[SearchJsonKey.ImageHeight].int16
        width = json?[SearchJsonKey.ImageWidth].int16
        takenDate = json?[SearchJsonKey.ImageDateTime].date
        largeUrl =  json?[SearchJsonKey.ThumbnailLarge].url
        mediumUrl = json?[SearchJsonKey.Thumbnail_Medium].url
        smalURl = json?[SearchJsonKey.ThumbnailSmall].url
        videoPreviewURL = json?[SearchJsonKey.VideoPreview].url
        
        artist = json?[SearchJsonKey.Artist].string
        album = json?[SearchJsonKey.Album].string
        title = json?[SearchJsonKey.Title].string
        
        if let durStr = json?[SearchJsonKey.Duration].stringValue, durStr.count > 0 {
            duration = Double( Double(durStr)! / 1000.0)
        }
        
        if let genreresponse = json?[SearchJsonKey.Genre].string {
            genre = genreresponse.components(separatedBy: ",")
        }
        
        if let slideshow = json?[SearchJsonKey.VideoSlideshow].string, slideshow.count > 0 {
            videoSlideshow = slideshow == "true" ? true : false
        }
        
        videoHLSPreview = json?[SearchJsonKey.VideoHLSPreview].url
    }
}

class SearchItemResponse: ObjectRequestResponse {
    
    var createdDate: Date?
    var lastModifiedDate: Date?
    var id: Int64?
    var hash: String?
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
        hash = json?[SearchJsonKey.hash].string
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
        albums = json?[SearchJsonKey.album].array?.flatMap{ $0.string }
        childCount = json?[SearchJsonKey.ChildCount].int64
    }
}

class SearchResponse: ObjectRequestResponse {
    
    var list: Array<SearchItemResponse> = []
    
    override func mapping() {
        let  tmpList = json?.array
        if let result = tmpList?.flatMap( {SearchItemResponse(withJSON: $0)}) {
            list = result
        }
    }
}

class UnifiedSearchResponse: ObjectRequestResponse {
    var list: Array<SearchItemResponse> = []
    
    override func mapping() {
        let tmpList = json?.dictionary?[SearchJsonKey.foundItems]?.array
        if let result = tmpList?.flatMap({ SearchItemResponse(withJSON: $0)}) {
            list = result
        }
    }
}

class SuggestionResponse: ObjectRequestResponse {
    var list: Array<SuggestionObject> = []
    
    override func mapping() {
        let tmpList = json?.array
        if let result = tmpList?.flatMap( { SuggestionObject(withJSON: $0)} ) {
            list = result
        }
    }
}

class SuggestionObject: ObjectRequestResponse {
    var text: String?
    var highlightedText: NSMutableAttributedString!
    
    override func mapping() {
        self.text = json?["text"].string
        self.highlightedText = getHighlightedText(string: json?["highlightedText"].string)
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
            attributedString.addAttributes([NSAttributedStringKey.foregroundColor : ColorConstants.darcBlueColor], range: NSMakeRange(0, highlightedText.length))
            attributedString.addAttributes([NSAttributedStringKey.foregroundColor : ColorConstants.blueColor], range: highlightedText.range(of: sub))
            attributedString.addAttributes([NSAttributedStringKey.font : UIFont.TurkcellSaturaDemFont(size: 15)], range: NSMakeRange(0, highlightedText.length))
            return attributedString
        }
        return nil
    }
}
