//
//  PlacesService.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 22.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class PlacesService: BaseRequestService {

//    func getPlacesList(param: PlacesParameters, success:@escaping SuccessResponse, fail:@escaping FailResponse) {
//        debugLog("SearchService suggestion")
//
//        let handler = BaseResponseHandler<PlacesServiceResponse, ObjectRequestResponse>(success: success, fail: fail)
//        executeGetRequest(param: param, handler: handler)
//    }
    
    func getPlacesPage(param: PlacesPageParameters, success:@escaping SuccessResponse, fail:@escaping FailResponse) {
        debugLog("PlacesService getPlacesPage")
        
        let handler = BaseResponseHandler<PlacesPageResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func getPlacesAlbum(id: Int, status: ItemStatus, success:@escaping AlbumOperationResponse, fail:@escaping FailResponse) {
        debugLog("PlacesService getPlacesAlbumWithID")
        
        let param = PlacesAlbumParameters(id: id, status: status)
        
        let handler = BaseResponseHandler<AlbumResponse, ObjectRequestResponse>(success: { response in
            if let response = response as? AlbumResponse, let album = response.list.first {
                success(album)
            } else {
                fail(ErrorResponse.failResponse(response))
            }
        }, fail: fail)
        
        executeGetRequest(param: param, handler: handler)
    }
    
    func deletePhotosFromAlbum(uuid: String, photos: [Item], success: PhotosAlbumOperation?, fail: FailResponse?) {
        debugLog("PeopleService deletePhotosFromAlbum")
        
        let parameters = DeletePhotosFromPlacesAlbum(albumUUID: uuid, photos: photos)
        
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { _  in
            debugLog("PeopleService deletePhotosFromAlbum success")
            
            success?()
        }, fail: fail)
        executePutRequest(param: parameters, handler: handler)
    }
}

final class PlacesItemsService: RemoteItemsService {
    private let service = PlacesService(transIdLogging: true)
    
    init(requestSize: Int) {
        super.init(requestSize: requestSize, fieldValue: .image)
    }
    
    override func nextItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoteItems?, fail: FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        let param = PlacesPageParameters(pageSize: requestSize, pageNumber: currentPage)

        service.getPlacesPage(param: param, success: { [weak self] response in
            guard let response = response as? PlacesPageResponse else {
                fail?()
                return
            }

            success?(response.list.map({ PlacesItem(response: $0) }))
            self?.currentPage += 1
            
            self?.service.debugLogTransIdIfNeeded(headers: response.response?.allHeaderFields, method: "getPlaces")
        }, fail: { [weak self] error in
            error.showInternetErrorGlobal()
            fail?()
            self?.service.debugLogTransIdIfNeeded(errorResponse: error, method: "getPlaces")
        })
    }
}

final class PlacesParameters: BaseRequestParametrs {
    override var patch: URL {
        let searchWithParam = String(format: RouteRequests.places)
        
        return URL(string: searchWithParam, relativeTo: RouteRequests.baseUrl)!
    }
}

final class PlacesAlbumParameters: BaseRequestParametrs {
    private let id: Int
    private let status: ItemStatus
    
    init(id: Int, status: ItemStatus) {
        self.id = id
        self.status = status
    }
    
    override var patch: URL {
        let searchWithParam: String
        if status.isContained(in: [.hidden, .trashed]) {
            searchWithParam = String(format: RouteRequests.placesAlbumWithStatus, id, status.rawValue)
        } else {
            searchWithParam = String(format: RouteRequests.placesAlbum, id)
        }
        return URL(string: searchWithParam, relativeTo: RouteRequests.baseUrl)!
    }
}

final class PlacesPageParameters: BaseRequestParametrs {
    let pageSize: Int
    let pageNumber: Int
    
    init(pageSize: Int, pageNumber: Int) {
        self.pageSize = pageSize
        self.pageNumber = pageNumber
    }
    
    override var patch: URL {
        let searchWithParam = String(format: RouteRequests.placesPage, pageSize, pageNumber)
        return URL(string: searchWithParam, relativeTo: RouteRequests.baseUrl)!
    }
}

final class PlacesItem: Item {
    let responseObject: PlacesItemResponse
    
    init(response: PlacesItemResponse) {
        responseObject = response
        super.init(placesItemResponse: response)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
}
