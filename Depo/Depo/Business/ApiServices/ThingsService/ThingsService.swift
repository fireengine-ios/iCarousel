//
//  ThingsService.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 22.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class ThingsService: BaseRequestService {

//    func getThingsList(param: ThingsParameters, success:@escaping SuccessResponse, fail:@escaping FailResponse) {
//        debugLog("SearchService suggestion")
//        
//        let handler = BaseResponseHandler<ThingsServiceResponse, ObjectRequestResponse>(success: success, fail: fail)
//        executeGetRequest(param: param, handler: handler)
//    }
    
    func getThingsPage(param: ThingsPageParameters, success:@escaping SuccessResponse, fail:@escaping FailResponse) {
        debugLog("ThingsService getThingsPage")
        
        let handler = BaseResponseHandler<ThingsPageResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func getThingsAlbum(id: Int, isHidden: Bool, success:@escaping (_ album: AlbumServiceResponse) -> Void, fail:@escaping FailResponse) {
        debugLog("ThingsService getThingsAlbumWithID")
        
        let param = ThingsAlbumParameters(id: id, isHidden: isHidden)
        
        let handler = BaseResponseHandler<AlbumResponse, ObjectRequestResponse>(success: { response in
            if let response = response as? AlbumResponse, let album = response.list.first {
                success(album)
            } else {
                fail(ErrorResponse.failResponse(response))
            }
        }, fail: fail)
        
        executeGetRequest(param: param, handler: handler)
    }
    
    func deletePhotosFromAlbum(id: Int64, photos: [Item], success: PhotosAlbumOperation?, fail: FailResponse?) {
        debugLog("ThingsService deletePhotosFromAlbum")
        
        let parameters = DeletePhotosFromThingsAlbum(id: id, photos: photos)
        
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { _  in
            debugLog("ThingsService deletePhotosFromAlbum success")
            
            success?()
        }, fail: fail)
        executePostRequest(param: parameters, handler: handler)
    }
    
}

//final class ThingsParameters: BaseRequestParametrs {
//    override var patch: URL {
//        let searchWithParam = String(format: RouteRequests.things)
//        
//        return URL(string: searchWithParam, relativeTo: RouteRequests.baseUrl)!
//    }
//}

final class ThingsItemsService: RemoteItemsService {
    private let service = ThingsService(transIdLogging: true)
    
    init(requestSize: Int) {
        super.init(requestSize: requestSize, fieldValue: .image)
    }
    
    override func nextItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoteItems?, fail: FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        let param = ThingsPageParameters(pageSize: requestSize, pageNumber: currentPage)
        
        service.getThingsPage(param: param, success: { [weak self] response in
            guard let response = response as? ThingsPageResponse else {
                fail?()
                return
            }

            success?(response.list.map({ ThingsItem(response: $0) }))
            self?.currentPage += 1
            
            self?.service.debugLogTransIdIfNeeded(headers: response.response?.allHeaderFields, method: "getThings")
            
        }, fail: { [weak self] error in
            error.showInternetErrorGlobal()
            fail?()
            
            self?.service.debugLogTransIdIfNeeded(errorResponse: error, method: "getThings")
        })
    }
}

final class ThingsItem: Item {
    let responseObject: ThingsItemResponse
    
    init(response: ThingsItemResponse) {
        responseObject = response
        super.init(thingsItemResponse: response)
    }
    
    required init?(coder aDecoder: NSCoder) {
         return nil
    }
}

final class ThingsAlbumParameters: BaseRequestParametrs {
    private let id: Int
    private let isHidden: Bool
    
    init(id: Int, isHidden: Bool) {
        self.id = id
        self.isHidden = isHidden
    }
    
    override var patch: URL {
        let path = isHidden ? RouteRequests.thingsAlbumHidden : RouteRequests.thingsAlbum
        let searchWithParam = String(format: path, id)
        return URL(string: searchWithParam, relativeTo: RouteRequests.baseUrl)!
    }
}

final class ThingsPageParameters: BaseRequestParametrs {
    let pageSize: Int
    let pageNumber: Int
    
    init(pageSize: Int, pageNumber: Int) {
        self.pageSize = pageSize
        self.pageNumber = pageNumber
    }
    
    override var patch: URL {
        let searchWithParam = String(format: RouteRequests.thingsPage, pageSize, pageNumber)
        return URL(string: searchWithParam, relativeTo: RouteRequests.baseUrl)!
    }
}

final class DeletePhotosFromThingsAlbum: BaseRequestParametrs {
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
        let path: String = String(format: RouteRequests.thingsDeletePhotos, id)
        return URL(string: path, relativeTo: super.patch)!
    }
}
