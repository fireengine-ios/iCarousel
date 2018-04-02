//
//  CreateStoryService.swift
//  Depo
//
//  Created by Alexander Gurin on 8/10/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import SwiftyJSON

struct CreateStoryPath {
    
    static let createStory  = "/api/slideshow/create"
    
    static let preview      = "/api/slideshow/previewUrl"
    
    static let audioList    = "api/slideshow/audio/list?language=%@"
    
}

struct CreateStoryPropertyName {
    static let imageUUIDs   = "imageUUIDs"
    static let name         = "name"
    static let audioId      = "audioId"
    static let audioUUID    = "audioUUID"
    static let idString     = "id"
    static let fileName     = "fileName"
    static let type         = "type"
    static let path         = "path"
    static let downloadUrl  = "downloadUrl"
    static let uuid         = "uuid"
}

class CreateStory: BaseRequestParametrs {
    let title: String
    let imageUUids: [String]
    let musicId: Int64?
    let audioUuid: String?
    
    init (name: String, imageuuid: [String], musicUUID: String? = nil, musicId: Int64? = nil) {
        self.title = name
        self.imageUUids = imageuuid
        self.musicId = musicId
        self.audioUuid = musicUUID
    }
    
    override var requestParametrs: Any {
        var param: [String: Any] =  [CreateStoryPropertyName.imageUUIDs: imageUUids,
                                     CreateStoryPropertyName.name    :title]
        if let id = musicId {
            param = param + [CreateStoryPropertyName.audioId :id]
        }
        if let id = audioUuid {
            param = param + [CreateStoryPropertyName.audioUUID :id]
        }
        return param
    }
    
    override var patch: URL {
        return URL(string: CreateStoryPath.createStory, relativeTo: super.patch)!
    }
    
    override var header: RequestHeaderParametrs {
        return RequestHeaders.authification()
    }
}

class CreateStoryPreview: CreateStory {
    override var timeout: TimeInterval {
        return 300.0
    }
    
    override var patch: URL {
        return URL(string: CreateStoryPath.preview, relativeTo: super.patch)!
    }
    
}


class CreateStoryMusicList: BaseRequestParametrs {
    
    override var requestParametrs: Any {
        return Data()
    }
    
    override var patch: URL {
        let patch = String(format: CreateStoryPath.audioList, Device.locale)
        return URL(string: patch, relativeTo: super.patch)!
    }
}

class CreateStoryMusicListResponse: ObjectRequestResponse {
    
    var list: [CreateStoryMusicItem]?
    
    override func mapping() {
        let item = json?.array?.flatMap { CreateStoryMusicItem(withJSON: $0) }
        list = item
    }
}

class CreateStoryMusicItem: ObjectRequestResponse {
    var id: Int64?
    var fileName: String?
    var type: String?
    var path: URL?
    
    override func mapping() {
        id = json?[CreateStoryPropertyName.idString].int64
        fileName = json?[CreateStoryPropertyName.fileName].string
        type = json?[CreateStoryPropertyName.type].string
        path = json?[CreateStoryPropertyName.path].url
    }
}

class CreateResponse: ObjectRequestResponse {
    var id: Int64?
    
    override func mapping() {
        id = json?["value"].int64
    }
}

class CreateStoryMusicService: RemoteItemsService {
    
    /// server request don't have pagination
    /// but we need this logic for the same logic
    private var isGotAll = false
    
    init() {
        /// 9999 is any number
        super.init(requestSize: 9999, fieldValue: .audio)
    }
    
    func allItems(success: ListRemoveItems?, fail: FailRemoteItems?) {
        log.debug("CreateStoryMusicService allItems")
     
        let requestService = BaseRequestService()
        let  handler = BaseResponseHandler< CreateStoryMusicListResponse, ObjectRequestResponse>(success: {  resp  in
            if self.isGotAll {
                log.debug("CreateStoryMusicService allItems success with empty result")

                success?([])
                return
            }
            if let response = resp as? CreateStoryMusicListResponse,
                let list = response.list {
                let result = list.flatMap { WrapData(musicForCreateStory: $0) }
                self.isGotAll = true
                success?(result)
                
                log.debug("CreateStoryMusicService allItems success")
            } else {
                log.debug("CreateStoryMusicService allItems fail")

                fail?()
            }
        }, fail: { _  in
            log.debug("CreateStoryMusicService allItems fail")

            fail?()
        })

        requestService.executeGetRequest(param: CreateStoryMusicList(), handler: handler)
    }
    
    override func nextItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoveItems?, fail: FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        log.debug("CreateStoryMusicService nextItems")

        allItems(success: success, fail: fail)
    }
}

typealias CreateStorSuccess = () -> Void
typealias GetPreviewStorrySyccess = (_ responce: CreateStoryResponce) -> Void

class CreateStoryService: BaseRequestService {
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    func createStory(createStory: CreateStory, success: CreateStorSuccess?, fail: FailResponse?) {
        log.debug("CreateStoryMusicService createStory")

        let  handler = BaseResponseHandler< CreateResponse, ObjectRequestResponse>(success: { [weak self] resp in
            if let created = resp as? CreateResponse,
                created.isOkStatus {
                log.debug("CreateStoryMusicServic createStory success")

                self?.analyticsService.track(event: .createStory)
                success?()
            } else {
                log.debug("CreateStoryMusicService createStory fail")

                let erorr: Error = NSError(domain: "Create story ", code: -6000, userInfo: nil)
                fail?(.error(erorr))
            }
        }, fail: fail)
        executePostRequest(param: createStory, handler: handler)
    }
    
    func getPreview(preview: CreateStoryPreview, success: @escaping GetPreviewStorrySyccess, fail: @escaping FailResponse ) {
        log.debug("CreateStoryMusicService getPreview fail")

        let  handler = BaseResponseHandler<CreateStoryResponce, ObjectRequestResponse>(success: {  resp  in
            if let responce = resp as? CreateStoryResponce {
                log.debug("CreateStoryMusicService getPreview success")

                success(responce)
            } else {
                log.debug("CreateStoryMusicService getPreview fail")

                let erorr: Error = NSError(domain: "Create story ", code: -6000, userInfo: nil)
                fail(.error(erorr))
            }
        }, fail: { _  in
            log.debug("CreateStoryMusicService getPreview fail")

            let erorr: Error = NSError(domain: "Create story ", code: -6000, userInfo: nil)
            fail(.error(erorr))
        })
        executePostRequest(param: preview, handler: handler)
    }
}
