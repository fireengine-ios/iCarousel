//
//  PeopleService.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 22.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class PeopleService: BaseRequestService {
    
    func getPeopleList(param: PeopleParameters, success: @escaping SuccessResponse, fail: @escaping FailResponse) {
        log.debug("SearchService suggestion")
        
        let handler = BaseResponseHandler<PeopleServiceResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func getPeoplePage(param: PeoplePageParameters, success: @escaping SuccessResponse, fail: @escaping FailResponse) {
        log.debug("SearchService suggestion")
        
        let handler = BaseResponseHandler<PeoplePageResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func getPeopleAlbum(id: Int, success: @escaping (_ uuid: String) -> Void, fail: @escaping FailResponse) {
        let param = PeopleAlbumParameters(id: id)
        
        let handler = BaseResponseHandler<AlbumResponse, ObjectRequestResponse>(success: { (response) in
            if let response = response as? AlbumResponse, let albumUUID = response.list.first?.uuid {
                success(albumUUID)
            } else {
                fail(ErrorResponse.failResponse(response))
            }
        }, fail: fail)
        
       executeGetRequest(param: param, handler: handler)
    }
    
    func getAlbumsForPeopleItemWithID(_ id: Int, success: @escaping (_ albums: [AlbumServiceResponse]) -> Void, fail: @escaping FailResponse) {
        let param = PeopleAlbumsParameters(id: id)
        
        let handler = BaseResponseHandler<AlbumResponse, ObjectRequestResponse>(success: { (response) in
            if let response = response as? AlbumResponse {
                success(response.list)
            } else {
                fail(ErrorResponse.failResponse(response))
            }
        }, fail: fail)
        
        executeGetRequest(param: param, handler: handler)
    }
}

class PeopleItemsService: RemoteItemsService {
    let service = PeopleService()
    
    init(requestSize: Int) {
        super.init(requestSize: requestSize, fieldValue: .image)
    }
    
    override func nextItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoveItems?, fail:FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        let param = PeoplePageParameters(pageSize: requestSize, pageNumber: currentPage)
        
        service.getPeoplePage(param: param, success: { [weak self] (response) in
            if let response = response as? PeoplePageResponse, !response.list.isEmpty {
                success?(response.list.map({ PeopleItem(response: $0) }))
                self?.currentPage += 1
            } else {
                fail?()
            }
        }) { (error) in
            fail?()
        }
    }
}

class PeopleParameters: BaseRequestParametrs {
    override var patch: URL {
        let searchWithParam = String(format: RouteRequests.people)
        return URL(string: searchWithParam, relativeTo:RouteRequests.BaseUrl)!
    }
}

class PeopleAlbumParameters: BaseRequestParametrs {
    let id: Int
    
    init(id: Int) {
        self.id = id
    }
    
    override var patch: URL {
        let searchWithParam = String(format: RouteRequests.peopleAlbum, id)
        return URL(string: searchWithParam, relativeTo:RouteRequests.BaseUrl)!
    }
}

class PeopleAlbumsParameters: BaseRequestParametrs {
    let id: Int
    
    init(id: Int) {
        self.id = id
    }
    
    override var patch: URL {
        let searchWithParam = String(format: RouteRequests.peopleAlbums, id)
        return URL(string: searchWithParam, relativeTo:RouteRequests.BaseUrl)!
    }
}

class PeoplePageParameters: BaseRequestParametrs {
    let pageSize: Int
    let pageNumber: Int
    
    init(pageSize: Int, pageNumber: Int) {
        self.pageSize = pageSize
        self.pageNumber = pageNumber
    }
    
    override var patch: URL {
        let searchWithParam = String(format: RouteRequests.peoplePage, pageSize, pageNumber)
        return URL(string: searchWithParam, relativeTo:RouteRequests.BaseUrl)!
    }
}

class PeopleItem: Item {
    let responseObject: PeopleItemResponse
    
    init(response: PeopleItemResponse) {
        responseObject = response
        super.init(peopleItemResponse: response)
    }
}
