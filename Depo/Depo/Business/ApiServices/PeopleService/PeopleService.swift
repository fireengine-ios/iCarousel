//
//  PeopleService.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 22.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

enum FaceImageType {
    case people
    case places
    case things
    
    var description: String {
        switch self {
        case .people:
            return "People"
        case .places:
            return "Places"
        case .things:
            return "Things"
        }
    }
    
    var footerDescription: String {
        switch self {
        case .people:
            return TextConstants.faceImageFaceRecognition
        case .places:
            return TextConstants.faceImagePlaceRecognition
        case .things:
            return TextConstants.faceImageThingRecognition
        }
    }
    
    var myStreamType: MyStreamType {
        switch self {
        case .people:
            return .people
        case .places:
            return .places
        case .things:
            return .things
        }
    }
}

final class FaceImageService: BaseRequestService {
    
    func getThumbnails(param: FaceImageThumbnailsParameters, success: @escaping SuccessResponse, fail: @escaping FailResponse) {
        debugLog("FaceImageService Thumbnails")
        
        let handler = BaseResponseHandler<FaceImageThumbnailsResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
}

final class FaceImageThumbnailsParameters: BaseRequestParametrs {
    
    private let type: FaceImageType
    
    init(withType type: FaceImageType) {
        self.type = type
    }
    
    override var patch: URL {
        let format: String
        switch type {
            case .people: format = RouteRequests.peopleThumbnails
            case .places: format = RouteRequests.placesThumbnails
            case .things: format = RouteRequests.thingsThumbnails
        }
        
        let searchWithParam = String(format: format)
        return URL(string: searchWithParam, relativeTo: RouteRequests.baseUrl)!
    }
}


final class PeopleService: BaseRequestService {
    
    func getPeopleList(param: PeopleParameters, success: @escaping SuccessResponse, fail: @escaping FailResponse) {
        debugLog("PeopleService getPeopleList")
        
        let handler = BaseResponseHandler<PeopleServiceResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func getPeoplePage(param: PeoplePageParameters, success: @escaping SuccessResponse, fail: @escaping FailResponse) {
        debugLog("PeopleService getPeoplePage")
        
        let handler = BaseResponseHandler<PeoplePageResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func getPeopleAlbum(id: Int, isHidden: Bool, success:@escaping (_ album: AlbumServiceResponse) -> Void, fail:@escaping FailResponse) {
        debugLog("PeopleService getPeopleAlbumWithID")
        
        let param = PeopleAlbumParameters(id: id, isHidden: isHidden)
        
        let handler = BaseResponseHandler<AlbumResponse, ObjectRequestResponse>(success: { response in
            if let response = response as? AlbumResponse, let album = response.list.first {
                success(album)
            } else {
                fail(ErrorResponse.failResponse(response))
            }
        }, fail: fail)
        
        executeGetRequest(param: param, handler: handler)
    }
    
    func getAlbumsForPeopleItemWithID(_ id: Int, success: @escaping (_ albums: [AlbumServiceResponse]) -> Void, fail: @escaping FailResponse) -> URLSessionTask {
        debugLog("PeopleService getAlbumsForPeopleItemWithID")
        
        let param = PeopleAlbumsParameters(id: id)
        
        let handler = BaseResponseHandler<AlbumResponse, ObjectRequestResponse>(success: { response in
            if let response = response as? AlbumResponse {
                success(response.list)
            } else {
                fail(ErrorResponse.failResponse(response))
            }
        }, fail: fail)
        
        return executeGetRequest(param: param, handler: handler)
    }
    
    func searchPeople(text: String, success:@escaping SuccessResponse, fail:@escaping FailResponse) {
        debugLog("PeopleService searchPeople")
        
        let param = PeopleSearchParameters(text: text)
        
        let handler = BaseResponseHandler<PeopleServiceResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func changePeopleVisibility(peoples: [PeopleItem], success:@escaping SuccessResponse, fail:@escaping FailResponse) {
        debugLog("PeopleService changePeopleVisibility")
        
        let param = PeopleChangeVisibilityParameters(peoples: peoples)
        
        let handler = BaseResponseHandler<PeopleServiceResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePutRequest(param: param, handler: handler)
    }
    
    func mergePeople(personId: Int64, targetPersonId: Int64, success:@escaping SuccessResponse, fail:@escaping FailResponse) {
        debugLog("PeopleService mergePeople")
        
        let param = PeopleMergeParameters(personId: personId, targetPersonId: targetPersonId)

        let handler = BaseResponseHandler<PeopleServiceResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePatchRequest(param: param, handler: handler)
    }
    
    func changePeopleName(personId: Int64, name: String, success:@escaping SuccessResponse, fail:@escaping FailResponse) {
        debugLog("PeopleService changePeopleName")
        
        let param = PeopleChangeNameParameters(personId: personId, name: name)
        
        let handler = BaseResponseHandler<PeopleServiceResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: param, handler: handler)
    }
    
    func deletePhotosFromAlbum(id: Int64, photos: [Item], success: PhotosAlbumOperation?, fail: FailResponse?) {
        debugLog("PeopleService deletePhotosFromAlbum")
        
        let parameters = DeletePhotosFromPeopleAlbum(id: id, photos: photos)
        
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { response  in
            debugLog("PeopleService deletePhotosFromAlbum success")
            
            success?()
        }, fail: fail)
        executePostRequest(param: parameters, handler: handler)
    }
    
}

final class PeopleItemsService: RemoteItemsService {
    private let service = PeopleService(transIdLogging: true)
    
    init(requestSize: Int) {
        super.init(requestSize: requestSize, fieldValue: .image)
    }
    
    override func nextItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoteItems?, fail: FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        let param = PeoplePageParameters(pageSize: requestSize, pageNumber: currentPage)
        
        service.getPeoplePage(param: param, success: { [weak self] response in
            guard let response = response as? PeoplePageResponse else {
                fail?()
                return
            }
            
            success?(response.list.map({ PeopleItem(response: $0) }))
            self?.currentPage += 1
            
            self?.service.debugLogTransIdIfNeeded(headers: response.response?.allHeaderFields, method: "getPeople")
            
        }, fail: { [weak self] error in
            error.showInternetErrorGlobal()
            fail?()
            
            self?.service.debugLogTransIdIfNeeded(errorResponse: error, method: "getPeople")
        })
    }
    
    func searchPeople(text: String, success: ListRemoteItems?, fail: FailRemoteItems?) {
        service.searchPeople(text: text, success: { response in
            if let response = response as? PeopleServiceResponse {
                success?(response.list.map({ PeopleItem(response: $0) }))
            } else {
                fail?()
            }
        }, fail: { error in
            error.showInternetErrorGlobal()
            fail?()
        })
    }

}

final class PeopleParameters: BaseRequestParametrs {
    override var patch: URL {
        let searchWithParam = String(format: RouteRequests.people)
        return URL(string: searchWithParam, relativeTo: RouteRequests.baseUrl)!
    }
}

final class PeopleAlbumParameters: BaseRequestParametrs {
    private let id: Int
    private let isHidden: Bool
    
    init(id: Int, isHidden: Bool) {
        self.id = id
        self.isHidden = isHidden
    }
    
    override var patch: URL {
        let path = isHidden ? RouteRequests.peopleAlbumHidden: RouteRequests.peopleAlbum
        let searchWithParam = String(format: path, id)
        return URL(string: searchWithParam, relativeTo: RouteRequests.baseUrl)!
    }
}

final class PeopleAlbumsParameters: BaseRequestParametrs {
    private let id: Int
    
    init(id: Int) {
        self.id = id
    }
    
    override var patch: URL {
        let searchWithParam = String(format: RouteRequests.peopleAlbums, id)
        return URL(string: searchWithParam, relativeTo: RouteRequests.baseUrl)!
    }
}

final class PeoplePageParameters: BaseRequestParametrs {
    private let pageSize: Int
    private let pageNumber: Int
    
    init(pageSize: Int, pageNumber: Int) {
        self.pageSize = pageSize
        self.pageNumber = pageNumber
    }
    
    override var patch: URL {
        let searchWithParam = String(format: RouteRequests.peoplePage, pageSize, pageNumber)
        return URL(string: searchWithParam, relativeTo: RouteRequests.baseUrl)!
    }
}

final class PeopleChangeVisibilityParameters: BaseRequestParametrs {
    private let peoples: [PeopleItem]
    
    init(peoples: [PeopleItem]) {
        self.peoples = peoples
    }
    
    override var requestParametrs: Any {
        var dict: [String: Any] = [:]
        
        peoples.forEach {
            if let id = $0.responseObject.id, let isVisibility = $0.responseObject.visible {
                dict.updateValue(isVisibility, forKey: "\(id)")
            }
        }
    
        return dict
    }
    
    override var patch: URL {
        let searchWithParam = String(format: RouteRequests.personVisibility)
        return URL(string: searchWithParam, relativeTo: RouteRequests.baseUrl)!
    }
}

final class PeopleSearchParameters: BaseRequestParametrs {
    private let text: String
    
    init(text: String) {
        self.text = text
    }
    
    override var patch: URL {
        let searchWithParam = String(format: RouteRequests.peopleSearch, text)
        return URL.encodingURL(string: searchWithParam, relativeTo: RouteRequests.baseUrl)!
    }
}

final class PeopleMergeParameters: BaseRequestParametrs {
    private let personId: Int64
    private let targetPersonId: Int64
    
    init(personId: Int64, targetPersonId: Int64) {
        self.personId = personId
        self.targetPersonId = targetPersonId
    }
    
    override var requestParametrs: Any {
        return "\(targetPersonId)"
    }
    
    override var patch: URL {
        let searchWithParam = String(format: RouteRequests.peopleMerge, personId)
        return URL(string: searchWithParam, relativeTo: RouteRequests.baseUrl)!
    }
}

final class PeopleChangeNameParameters: BaseRequestParametrs {
    private let personId: Int64
    private let name: String
    
    init(personId: Int64, name: String) {
        self.personId = personId
        self.name = name
    }
    
    override var requestParametrs: Any {
        return name
    }
    
    override var header: RequestHeaderParametrs {
        var dict = super.header
        dict[HeaderConstant.ContentType] = "application/json;charset=UTF-8"
        return dict
    }
    
    override var patch: URL {
        let searchWithParam = String(format: RouteRequests.peopleChangeName, personId)
        return URL(string: searchWithParam, relativeTo: RouteRequests.baseUrl)!
    }
}

final class DeletePhotosFromPeopleAlbum: BaseRequestParametrs {
    let id: Int64
    let photos: [Item]
    
    init (id: Int64, photos: [Item]) {
        self.id = id
        self.photos = photos
    }
    
    override var requestParametrs: Any {
        let photosUUID = photos.map { $0.id }
        return photosUUID
    }
    
    override var patch: URL {
        let path: String = String(format: RouteRequests.peopleDeletePhotos, id)
        return URL(string: path, relativeTo: super.patch)!
    }
}

final class PeopleItem: Item {
    let responseObject: PeopleItemResponse
    
    init(response: PeopleItemResponse) {
        responseObject = response
        super.init(peopleItemResponse: response)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
}
