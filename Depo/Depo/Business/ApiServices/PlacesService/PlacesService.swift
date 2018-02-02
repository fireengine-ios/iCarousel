//
//  PlacesService.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 22.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class PlacesService: BaseRequestService {

    func getPlacesList(param: PlacesParameters, success:@escaping SuccessResponse, fail:@escaping FailResponse) {
        log.debug("SearchService suggestion")
        
        let handler = BaseResponseHandler<PlacesServiceResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func getPlacesPage(param: PlacesPageParameters, success:@escaping SuccessResponse, fail:@escaping FailResponse) {
        log.debug("SearchService suggestion")
        
        let handler = BaseResponseHandler<PlacesPageResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func getPlacesAlbum(id: Int, success:@escaping (_ uuid: String) -> Void, fail:@escaping FailResponse) {
        let param = PlacesAlbumParameters(id: id)
        
        let handler = BaseResponseHandler<AlbumResponse, ObjectRequestResponse>(success: { (response) in
            if let response = response as? AlbumResponse, let albumUUID = response.list.first?.uuid {
                success(albumUUID)
            } else {
                fail(ErrorResponse.failResponse(response))
            }
        }, fail: fail)
        
        executeGetRequest(param: param, handler: handler)
    }
}

class PlacesItemsService: RemoteItemsService {
    let service = PlacesService()
    
    init(requestSize: Int) {
        super.init(requestSize: requestSize, fieldValue: .image)
    }
    
    override func nextItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoveItems?, fail:FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        let param = PlacesPageParameters(pageSize: requestSize, pageNumber: currentPage)

        service.getPlacesPage(param: param, success: { [weak self] (response) in
            if let response = response as? PlacesPageResponse, !response.list.isEmpty {
                success?(response.list.map({ PlacesItem(response: $0) }))
                self?.currentPage += 1
            } else {
                fail?()
            }
        }) { (error) in
            fail?()
        }
    }
}

class PlacesParameters: BaseRequestParametrs {
    override var patch: URL {
        let searchWithParam = String(format:RouteRequests.places)
        
        return URL(string: searchWithParam, relativeTo:RouteRequests.BaseUrl)!
    }
}

class PlacesAlbumParameters: BaseRequestParametrs {
    let id: Int
    
    init(id: Int) {
        self.id = id
    }
    
    override var patch: URL {
        let searchWithParam = String(format: RouteRequests.placesAlbum, id)
        return URL(string: searchWithParam, relativeTo:RouteRequests.BaseUrl)!
    }
}

class PlacesPageParameters: BaseRequestParametrs {
    let pageSize: Int
    let pageNumber: Int
    
    init(pageSize: Int, pageNumber: Int) {
        self.pageSize = pageSize
        self.pageNumber = pageNumber
    }
    
    override var patch: URL {
        let searchWithParam = String(format: RouteRequests.placesPage, pageSize, pageNumber)
        return URL(string: searchWithParam, relativeTo:RouteRequests.BaseUrl)!
    }
}

class PlacesItem: Item {
    let responseObject: PlacesItemResponse
    
    init(response: PlacesItemResponse) {
        responseObject = response
        super.init(placesItemResponse: response)
    }
}
