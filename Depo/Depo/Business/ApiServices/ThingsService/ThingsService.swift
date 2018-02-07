//
//  ThingsService.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 22.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class ThingsService: BaseRequestService {

    func getThingsList(param: ThingsParameters, success:@escaping SuccessResponse, fail:@escaping FailResponse) {
        log.debug("SearchService suggestion")
        
        let handler = BaseResponseHandler<ThingsServiceResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func getThingsPage(param: ThingsPageParameters, success:@escaping SuccessResponse, fail:@escaping FailResponse) {
        log.debug("SearchService suggestion")
        
        let handler = BaseResponseHandler<ThingsPageResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func getThingsAlbum(id: Int, success:@escaping (_ album: AlbumServiceResponse) -> Void, fail:@escaping FailResponse) {
        let param = PlacesAlbumParameters(id: id)
        
        let handler = BaseResponseHandler<AlbumResponse, ObjectRequestResponse>(success: { (response) in
            if let response = response as? AlbumResponse, let album = response.list.first {
                success(album)
            } else {
                fail(ErrorResponse.failResponse(response))
            }
        }, fail: fail)
        
        executeGetRequest(param: param, handler: handler)
    }
}

class ThingsParameters: BaseRequestParametrs {
    override var patch: URL {
        let searchWithParam = String(format:RouteRequests.things)
        
        return URL(string: searchWithParam, relativeTo:RouteRequests.BaseUrl)!
    }
}

class ThingsItemsService: RemoteItemsService {
    let service = ThingsService()
    
    init(requestSize: Int) {
        super.init(requestSize: requestSize, fieldValue: .image)
    }
    
    override func nextItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoveItems?, fail:FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        let param = ThingsPageParameters(pageSize: requestSize, pageNumber: currentPage)
        
        service.getThingsPage(param: param, success: { [weak self] (response) in
            if let response = response as? ThingsPageResponse, !response.list.isEmpty {
                success?(response.list.map({ ThingsItem(response: $0) }))
                self?.currentPage += 1
            } else {
                fail?()
            }
        }) { (error) in
            fail?()
        }
    }
}

class ThingsItem: Item {
    let responseObject: ThingsItemResponse
    
    init(response: ThingsItemResponse) {
        responseObject = response
        super.init(thingsItemResponse: response)
    }
}

class ThingsAlbumParameters: BaseRequestParametrs {
    let id: Int
    
    init(id: Int) {
        self.id = id
    }
    
    override var patch: URL {
        let searchWithParam = String(format: RouteRequests.thingsAlbum, id)
        return URL(string: searchWithParam, relativeTo:RouteRequests.BaseUrl)!
    }
}

class ThingsPageParameters: BaseRequestParametrs {
    let pageSize: Int
    let pageNumber: Int
    
    init(pageSize: Int, pageNumber: Int) {
        self.pageSize = pageSize
        self.pageNumber = pageNumber
    }
    
    override var patch: URL {
        let searchWithParam = String(format: RouteRequests.thingsPage, pageSize, pageNumber)
        return URL(string: searchWithParam, relativeTo:RouteRequests.BaseUrl)!
    }
}
