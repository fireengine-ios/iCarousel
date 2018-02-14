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
    
    func getPeopleAlbum(id: Int, success:@escaping (_ album: AlbumServiceResponse) -> Void, fail:@escaping FailResponse) {
        let param = PeopleAlbumParameters(id: id)
        
        let handler = BaseResponseHandler<AlbumResponse, ObjectRequestResponse>(success: { (response) in
            if let response = response as? AlbumResponse, let album = response.list.first {
                success(album)
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
    
    func searchPeople(text: String, success:@escaping SuccessResponse, fail:@escaping FailResponse) {
        let param = PeopleSearchParameters(text: text)
        
        let handler = BaseResponseHandler<PeopleServiceResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func changePeopleVisibility(peoples: [PeopleItem], success:@escaping SuccessResponse, fail:@escaping FailResponse) {
        let param = PeopleChangeVisibilityParameters(peoples: peoples)
        
        let handler = BaseResponseHandler<PeopleServiceResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePutRequest(param: param, handler: handler)
    }
    
    func mergePeople(personId: Int64, targetPersonId: Int64, success:@escaping SuccessResponse, fail:@escaping FailResponse) {
        let param = PeopleMergeParameters(personId: personId, targetPersonId: targetPersonId)

        let handler = BaseResponseHandler<PeopleServiceResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePatchRequest(param: param, handler: handler)
    }
    
    func changePeopleName(personId: Int64, name: String, success:@escaping SuccessResponse, fail:@escaping FailResponse) {
        let param = PeopleChangeNameParameters(personId: personId, name: name)
        
        let handler = BaseResponseHandler<PeopleServiceResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: param, handler: handler)
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
    
    func searchPeople(text: String, success: ListRemoveItems?, fail: FailRemoteItems?) {
        service.searchPeople(text: text, success: { (response) in
            if let response = response as? PeopleServiceResponse, !response.list.isEmpty {
                success?(response.list.map({ PeopleItem(response: $0) }))
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

class PeopleChangeVisibilityParameters: BaseRequestParametrs {
    let peoples: [PeopleItem]
    
    init(peoples: [PeopleItem]) {
        self.peoples = peoples
    }
    
    override var requestParametrs: Any {
        var dict: [String: Any] = [:]
        
        peoples.forEach {
            if let id = $0.responseObject.id
                ,let isVisibility = $0.responseObject.visible{
                dict.updateValue(!isVisibility, forKey: "\(id)")
            }
        }
    
        return dict
    }
    
    override var patch: URL {
        let searchWithParam = String(format: RouteRequests.personVisibility)
        return URL(string: searchWithParam, relativeTo:RouteRequests.BaseUrl)!
    }
}

class PeopleSearchParameters: BaseRequestParametrs {
    let text: String
    
    init(text: String) {
        self.text = text
    }
    
    override var patch: URL {
        let searchWithParam = String(format: RouteRequests.peopleSearch, text)
        return URL(string: searchWithParam, relativeTo:RouteRequests.BaseUrl)!
    }
}

class PeopleMergeParameters: BaseRequestParametrs {
    let personId: Int64
    let targetPersonId: Int64
    
    init(personId: Int64, targetPersonId: Int64) {
        self.personId = personId
        self.targetPersonId = targetPersonId
    }
    
    override var requestParametrs: Any {
        return "\(targetPersonId)"
    }
    
    override var patch: URL {
        let searchWithParam = String(format: RouteRequests.peopleMerge, personId)
        return URL(string: searchWithParam, relativeTo:RouteRequests.BaseUrl)!
    }
}

class PeopleChangeNameParameters: BaseRequestParametrs {
    let personId: Int64
    let name: String
    
    init(personId: Int64, name: String) {
        self.personId = personId
        self.name = name
    }
    
    override var requestParametrs: Any {
        return name
    }
    
    override var patch: URL {
        let searchWithParam = String(format: RouteRequests.peopleChangeName, personId)
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
