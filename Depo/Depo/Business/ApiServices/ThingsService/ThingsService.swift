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
}

class ThingsParameters: BaseRequestParametrs {
    
    override var patch: URL {
        let searchWithParam = String(format:RouteRequests.things)
        
        return URL(string: searchWithParam, relativeTo:RouteRequests.BaseUrl)!
    }
}
