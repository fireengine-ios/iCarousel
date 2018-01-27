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
}

class PeopleParameters: BaseRequestParametrs {
    
    override var patch: URL {
        let searchWithParam = String(format:RouteRequests.people)
        
        return URL(string: searchWithParam, relativeTo:RouteRequests.BaseUrl)!
    }
}

