//
//  SearchService.swift
//  Depo
//
//  Created by Alexander Gurin on 7/9/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

enum SortType: CustomStringConvertible {
    typealias RawValue = Int
    
    case name
    case size
    case artist
    case album
    case date
    case imageDate
    case albumName
    
    var description: String {
        switch self {
        case .name      : return "name"
        case .albumName : return "label"
        case .size      : return "bytes"
        case .artist    : return "artist"
        case .album     : return "album"
        case .date      : return "createdDate"
        case .imageDate : return "metadata.Image-DateTime"
        }
    }
}


enum SortOrder: CustomStringConvertible {
    case asc
    case desc
    
    var description: String {
        switch self {
        case .asc  : return "ASC"
        case .desc : return "DESC"
        }
    }
}


enum FieldValue: CustomStringConvertible {
    case image
    case imageAndVideo
    case albums
    case video
    case document
    case audio
    case playLists
    case favorite
    case cropy
    case story
    case all
    
    var description: String {
        switch self {
        case .audio         : return "audio"
        case .playLists     : return "playList"
        case .image         : return "image"
        case .video         : return "video"
        case .albums        : return "album/photo"
        case .imageAndVideo : return "image%20OR%20video"
        case .document      : return "application%20OR%20text%20NOT%20directory"
        case .favorite      : return "true"
        case .cropy         : return "true"
        case .story         : return "true"
        case .all           : return ""
        }
    }
    
    var rawValue: String {
        switch self {
        case .audio         : return "musics"
        case .playLists     : return "playList"
        case .image         : return "images"
        case .albums        : return "album"
        case .video         : return "videos"
        case .imageAndVideo : return "photos_and_videos"
        case .document      : return "documents"
        case .favorite      : return "true"
        case .cropy         : return "true"
        case .story         : return "true"
        case .all           : return ""
        }
    }
}

enum SearchContentType: CustomStringConvertible {
    case content_type
    case cropy
    case favorite
    case album
    case story
    
    var description: String {
        switch self {
        case .content_type : return "content_type"
        case .cropy        : return "metadata.Cropy"
        case .favorite     : return "metadata.X-Object-Meta-Favourite"
        case .album        : return "album/photo"
        case .story        : return "metadata.Video-Slideshow"
        }
    }
}

class SearchByFieldParameters: BaseRequestParametrs, Equatable {
    let fieldName: SearchContentType
    let fieldValue: FieldValue
    let sortBy: SortType
    let sortOrder: SortOrder
    let page: Int
    let size: Int
    let minified: Bool
    let hidden: Bool
    
    init(fieldName: SearchContentType = .content_type, fieldValue: FieldValue, sortBy: SortType, sortOrder: SortOrder, page: Int,
         size: Int, minified: Bool = false, hidden: Bool = true) {
        self.fieldName = fieldName
        self.fieldValue = fieldValue
        self.sortBy = sortBy
        self.sortOrder = sortOrder
        self.page = page
        self.size = size
        self.minified = minified
        self.hidden = hidden
    }
    
    override var patch: URL {
        var searchWithParam = String(format: RouteRequests.search,
                                     fieldName.description,
                                     fieldValue.description,
                                     sortBy.description,
                                     sortOrder.description,
                                     page.description,
                                     size.description)
        
        let mini = minified ? "true": "false"
        let mimifidedStr = String(format: "&minified=%@", mini)
        searchWithParam = searchWithParam.appending(mimifidedStr)
        
        if fieldValue.isContained(in: [.document, .favorite, .audio]) || !hidden {
            let notHiddenParameter = "&showHidden=false"
            searchWithParam = searchWithParam.appending(notHiddenParameter)
        }
        
        return URL(string: searchWithParam, relativeTo: super.patch)!
    }
}

func ==(lhs: SearchByFieldParameters, rhs: SearchByFieldParameters) -> Bool {
    return lhs.patch.absoluteString == rhs.patch.absoluteString
}

struct AdvancedSearchParameters: RequestParametrs {
    var timeout: TimeInterval {
        return NumericConstants.defaultTimeout
    }
    
    let sortBy: SortType
    let sortOrder: SortOrder
    let from: Int
    let size: Int /*max 50*/
    
    var requestParametrs: Any {
        return ""
    }
    
    var patch: URL {
        let name: String = "LifeBox"
        let searchWithParam = String(format: RouteRequests.advanceSearch,
                                     name, from.description,
                                     size.description,
                                     sortBy.description,
                                     sortOrder.description)
        
        return URL(string: searchWithParam, relativeTo: RouteRequests.baseUrl)!
    }
    
    var header: RequestHeaderParametrs {
        return RequestHeaders.authification()
    }
}

class UnifiedSearchParameters: BaseRequestParametrs {
    let text: String
    let category: FieldValue
    let sortBy: SortType
    let sortOrder: SortOrder
    let page: Int
    let size: Int
    
    init(text: String, category: FieldValue, sortBy: SortType, sortOrder: SortOrder, page: Int, size: Int) {
        self.text = text
        self.category = category
        self.page = page
        self.size = size
        self.sortBy = sortBy
        self.sortOrder = sortOrder
    }
    
    override var patch: URL {
        var searchWithParam = ""
        if (category == .all) {
            searchWithParam = String(format: RouteRequests.unifiedSearchWithoutCategory,
                                     text, page.description, size.description)
        } else {
            searchWithParam = String(format: RouteRequests.unifiedSearch,
                   text, category.rawValue,
                   page.description, size.description)
        }
//        let searchWithParam = String(format:RouteRequests.unifiedSearch,
//                                     text, category.rawValue,
//                                     page.description, size.description)
        
        return URL.encodingURL(string: searchWithParam, relativeTo: RouteRequests.baseUrl)!
    }
    
}

class SuggestionParametrs: BaseRequestParametrs {
    
    let text: String
    
    init(withText text: String) {
        self.text = text
    }

    override var patch: URL {
        let suggestionParameters = String(format: RouteRequests.suggestion, text)
        return URL.encodingURL(string: suggestionParameters, relativeTo: RouteRequests.baseUrl)!
    }
}

class AlbumParameters: BaseRequestParametrs {
    let fieldName: SearchContentType
    let sortBy: SortType
    let sortOrder: SortOrder
    let page: Int
    let size: Int
    
    init(fieldName: SearchContentType = .content_type, sortBy: SortType, sortOrder: SortOrder, page: Int, size: Int) {
        self.fieldName = fieldName
        self.sortBy = sortBy
        self.sortOrder = sortOrder
        self.page = page
        self.size = size
        
    }
    
    override var patch: URL {
        //static let albumList    = "/api/album?contentType=%@&page=%@&size=%@&sortBy=%@&sortOrder=%@"
        //'/album'+pagination parameters + 'contentType=' + contentType
        let searchWithParam = String(format: RouteRequests.albumList,
                                     fieldName.description,
                                     page.description,
                                     size.description,
                                     sortBy.description,
                                     sortOrder.description
                                     )
        
        return URL(string: searchWithParam, relativeTo: RouteRequests.baseUrl)!
    }
}

class AlbumDetalParameters: BaseRequestParametrs {
    let albumUUID: String
    let sortBy: SortType
    let sortOrder: SortOrder
    let page: Int
    let size: Int
    
    init(albumUuid: String, sortBy: SortType, sortOrder: SortOrder, page: Int, size: Int) {
        self.albumUUID = albumUuid
        self.sortBy = sortBy
        self.sortOrder = sortOrder
        self.page = page
        self.size = size
        
    }
    
    override var patch: URL {
        let searchWithParam = String(format: RouteRequests.details,
                                     albumUUID.description,
                                     page.description,
                                     size.description,
                                     sortBy.description,
                                     sortOrder.description
        )
        
        return URL(string: searchWithParam, relativeTo: RouteRequests.baseUrl)!
    }
}

class SearchService: BaseRequestService {
    
    @discardableResult
    func searchByField(param: SearchByFieldParameters, success:@escaping SuccessResponse, fail:@escaping FailResponse ) -> URLSessionTask {
        debugLog("SearchService searchByField")

        let handler = BaseResponseHandler<SearchResponse, ObjectRequestResponse>(success: success, fail: fail)
        return executeGetRequest(param: param, handler: handler)
    }
    
    func searchByName(param: AdvancedSearchParameters, success:@escaping SuccessResponse, fail:@escaping FailResponse ) {
        debugLog("SearchService searchByName")

        let handler = BaseResponseHandler<SearchResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func searchAlbums(param: AlbumParameters, success:@escaping SuccessResponse, fail:@escaping FailResponse ) {
        debugLog("SearchService searchAlbums")

        let handler = BaseResponseHandler<AlbumResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func searchContentAlbum(param: AlbumDetalParameters, success:@escaping SuccessResponse, fail:@escaping FailResponse ) {
        debugLog("SearchService searchContentAlbum")

        let handler = BaseResponseHandler<AlbumDetailResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func unifiedSearch(param: UnifiedSearchParameters, success:@escaping SuccessResponse, fail:@escaping FailResponse ) {
        debugLog("SearchService unifiedSearch")

        let handler = BaseResponseHandler<UnifiedSearchResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func suggestion(param: SuggestionParametrs, success:@escaping SuccessResponse, fail:@escaping FailResponse) {
        debugLog("SearchService suggestion")

        let handler = BaseResponseHandler<SuggestionResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
}
