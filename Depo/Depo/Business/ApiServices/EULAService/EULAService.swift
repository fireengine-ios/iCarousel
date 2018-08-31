//
//  EULAService.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 6/27/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import SwiftyJSON

struct EULAResponseKey {
    static let id = "id"
    static let createDate = "createDate"
    static let locale = "locale"
    static let content = "content"
}

class Eula: ObjectRequestResponse {
   
    var id: Int?
   
    var createDate: Date?
    
    var locale: String?
    
    var content: String?
    
    override func mapping() {
        
        id = json?[EULAResponseKey.id].int
        locale = json?[EULAResponseKey.locale].string
        content = json?[EULAResponseKey.content].string
        
        guard  let date = json?[EULAResponseKey.createDate].double else {
            return
        }
        
        createDate = Date(timeIntervalSince1970: date)
    }
}

struct EULAGet: RequestParametrs {
    var timeout: TimeInterval {
        return NumericConstants.defaultTimeout
    }
    
    var requestParametrs: Any {
        return ""
    }
    
    var patch: URL {
        let patch = String(format: RouteRequests.eulaGet, Device.locale)
        return URL(string: patch, relativeTo: RouteRequests.baseUrl)!
    }
    
    var header: RequestHeaderParametrs {
        return RequestHeaders.base()
    }
}

struct EULACheck: RequestParametrs {
    var timeout: TimeInterval {
        return NumericConstants.defaultTimeout
    }
    
    var requestParametrs: Any {
        return ""
    }
    
    var patch: URL {
        let patch = String(format: RouteRequests.eulaCheck, Device.locale)
        return URL(string: patch, relativeTo: RouteRequests.baseUrl)!
    }
    
    var header: RequestHeaderParametrs {
        return RequestHeaders.authification()
    }
}

struct  EULAApprove: RequestParametrs {
    var timeout: TimeInterval {
        return NumericConstants.defaultTimeout
    }
    
    let id: Int
    
    var requestParametrs: Any {
        return ""
    }
    
    var patch: URL {
        let patch = String(format: RouteRequests.eulaApprove, id )
        return URL(string: patch, relativeTo: RouteRequests.baseUrl)!
    }
    
    var header: RequestHeaderParametrs {
        return RequestHeaders.authification()
    }

}

class EulaService: BaseRequestService {


    func eulaGet(sucess: SuccessResponse?, fail: FailResponse? ) {
        debugLog("EulaService eulaGet")

        let eula = EULAGet()
        let handler = BaseResponseHandler<Eula, ObjectRequestResponse>(success: sucess, fail: fail)
        executeGetRequest(param: eula, handler: handler)
    }
    
    func eulaCheck(success: SuccessResponse?, fail: FailResponse?) {
        debugLog("EulaService eulaCheck")

        let eula = EULACheck()
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: eula, handler: handler)
    }

    func eulaApprove(eulaId: Int, sucess: SuccessResponse?, fail: FailResponse? ) {
        debugLog("EulaService eulaApprove")
        
        let eula = EULAApprove(id: eulaId)
        
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: sucess, fail: fail)
        executeGetRequest(param: eula, handler: handler)

        
    }
}
