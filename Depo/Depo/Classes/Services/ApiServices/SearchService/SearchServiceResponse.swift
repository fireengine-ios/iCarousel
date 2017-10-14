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
    static let id = "id"
    static let hash = "hash"
    static let iOSMetaHash = "X-Object-Meta-Ios-Metadata-Hash"
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
    
    // music metadata
    
    static let Artist = "Artist"
    static let Album = "Album"
    static let Title = "Title"
    static let Duration = "Duration"
    static let Genre = "Genre"
}

class BaseMetaData: ObjectRequestResponse {
    var favourite: Bool
    var medaData: BaseMetaData?
    
    required init(withJSON: JSON?, contentType: String) {

        favourite = withJSON?[SearchJsonKey.favourite].boolFromString ?? false

        super.init(withJSON: withJSON)
        
        if contentType.hasPrefix("image") {
            medaData = ImageAndVideoMetaData(withJSON: self.json, contentType: "")
            return
        }
        if contentType.hasPrefix("video") {
            medaData = ImageAndVideoMetaData(withJSON: self.json, contentType: "")
            return
        }
        
        if contentType.hasPrefix("audio") {
            medaData = MusicMetaData(withJSON: self.json, contentType: "")
            return
        }
        
        if contentType.hasPrefix("application") {
            medaData = DocumentMetaData(withJSON: self.json, contentType: "")
            return
        }
    }
    
    required init(json: Data?, headerResponse: HTTPURLResponse?) {
        fatalError("init(json:headerResponse:) has not been implemented")
    }
    
    required init(withJSON: JSON?) {
        fatalError("init(withJSON:) has not been implemented")
    }
}

class ImageAndVideoMetaData: BaseMetaData {
    var height: Int16?
    var width: Int16?
    var uploadDate: Date?
    var largeUrl: URL?
    var mediumUrl: URL?
    var smalURl: URL?
    var duration: Double?
    
    override func mapping() {
        height = json?[SearchJsonKey.ImageHeight].int16
        width = json?[SearchJsonKey.ImageWidth].int16
        uploadDate = json?[SearchJsonKey.ImageDateTime].date
        largeUrl =  json?[SearchJsonKey.ThumbnailLarge].url
        mediumUrl = json?[SearchJsonKey.Thumbnail_Medium].url
        smalURl = json?[SearchJsonKey.ThumbnailSmall].url
        
        if let durStr = json?[SearchJsonKey.Duration].stringValue,
            (durStr.characters.count > 0) {
            duration = Double( Double(durStr)! / 1000.0)
        }
    }
}

class MusicMetaData: BaseMetaData {
    var artist: String?
    var album: String?
    var title: String?
    var duration: Double?
    var genre =  [String]()
    
    override func mapping() {
        artist = json?[SearchJsonKey.Artist].string
        album = json?[SearchJsonKey.Album].string
        title = json?[SearchJsonKey.Title].string
        
        if let durStr = json?[SearchJsonKey.Duration].stringValue,
            (durStr.characters.count > 0) {
            duration = Double( Double(durStr)! / 1000.0)
        }
        
        if let genreresponse = json?[SearchJsonKey.Genre].string {
            genre = genreresponse.components(separatedBy: ",")
        }
    }
}

class DocumentMetaData: BaseMetaData {
    
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
    var album: Array<JSON>?
    var subordinates: Array<JSON>?
    var location: Any? // TODO Add!
    
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
        metadata = BaseMetaData(withJSON: json?[SearchJsonKey.metadata],
                                contentType: contentType ?? "")
        
        folder = json?[SearchJsonKey.folder].bool
        uploaderDeviceType = json?[SearchJsonKey.uploaderDeviceType].string
        parent = json?[SearchJsonKey.parent].string
        tempDownloadURL = json?[SearchJsonKey.tempDownloadURL].url
        status = json?[SearchJsonKey.status].string
        subordinates = json?[SearchJsonKey.subordinates].array
        album = json?[SearchJsonKey.album].array
        
        if metadata?.medaData is ImageAndVideoMetaData{
            let meta = metadata?.medaData as! ImageAndVideoMetaData
            if let date = meta.uploadDate{
                createdDate = date
            }
        }
        
    }
}

class SearchResponse: ObjectRequestResponse {
    
    var list: Array<SearchItemResponse> = []
    
    override func mapping() {
        let  tmpList = json?.array
        if let result = tmpList?.flatMap( {SearchItemResponse(withJSON: $0)} ){
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
