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
}

class PlacesParameters: BaseRequestParametrs {
    
    override var patch: URL {
        let searchWithParam = String(format:RouteRequests.places)
        
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
