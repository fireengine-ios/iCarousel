//
//  PeopleService.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 22.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class PeopleService: BaseRequestService {
    
    func getPeopleList(param: PeopleParameters, success:@escaping SuccessResponse, fail:@escaping FailResponse) {
        log.debug("SearchService suggestion")
        
        let handler = BaseResponseHandler<PeopleServiceResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func getPeoplePage(param: PeoplePageParameters, success:@escaping SuccessResponse, fail:@escaping FailResponse) {
        log.debug("SearchService suggestion")
        
        let handler = BaseResponseHandler<PeopleServiceResponse, ObjectRequestResponse>(success: success, fail: fail)
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
        
        // TO-DO: Delete when back-end will deploy
        if currentPage > 0 {
            success?([PeopleItem]())
            return
        }
        // END
        
        service.getPeoplePage(param: param, success: { [weak self] (response) in
            if let response = response as? PeopleServiceResponse {
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

class PeoplePageParameters: BaseRequestParametrs {
    
    let pageSize: Int
    let pageNumber: Int
    
    init(pageSize: Int, pageNumber: Int) {
        self.pageSize = pageSize
        self.pageNumber = pageNumber
    }
    
    override var patch: URL {
//        let searchWithParam = String(format: RouteRequests.peoplePage, pageSize, pageNumber)
//
//        return URL(string: searchWithParam, relativeTo:RouteRequests.BaseUrl)!
        
        // TO-DO: Use commented version when back-end will deploy
        
        let searchWithParam = String(format: RouteRequests.people)
        
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
