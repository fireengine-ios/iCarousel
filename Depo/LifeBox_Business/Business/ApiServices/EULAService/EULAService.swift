//
//  EULAService.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 6/27/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

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

struct EULAApprove: RequestParametrs {
    var timeout: TimeInterval {
        return NumericConstants.defaultTimeout
    }
    
    let id: Int
    let etkAuth: Bool?
    let kvkkAuth: Bool?
    let globalPermAuth: Bool?
    
    var requestParametrs: Any {
        var params: [String: Any] = [LbRequestkeys.eulaId: id]
        
        if let etkAuth = etkAuth {
            params[LbRequestkeys.etkAuth] = etkAuth
        }
        
        if let globalPermAuth = globalPermAuth {
            params[LbRequestkeys.globalPermAuth] = globalPermAuth
        }
        
        if let kvkkAuth = kvkkAuth {
            params[LbRequestkeys.kvkkAuth] = kvkkAuth
        }
        
        return params
    }
    
    var patch: URL {
        return URL(string: RouteRequests.eulaApprove, relativeTo: RouteRequests.baseUrl)!
    }
    
    var header: RequestHeaderParametrs {
        return RequestHeaders.authification()
    }

}

class EulaService: BaseRequestService {
    
    func eulaCheck(success: SuccessResponse?, fail: FailResponse?) {
        debugLog("EulaService eulaCheck")

        let eula = EULACheck()
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: eula, handler: handler)
    }

    func eulaApprove(eulaId: Int, etkAuth: Bool?, kvkkAuth: Bool?, globalPermAuth: Bool?, success: SuccessResponse?, fail: FailResponse? ) {
        debugLog("EulaService eulaApprove")
        
        let eula = EULAApprove(id: eulaId, etkAuth: etkAuth, kvkkAuth: kvkkAuth, globalPermAuth: globalPermAuth)
        
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: eula, handler: handler)
    }
    
    private let sessionManager: SessionManager = factory.resolve()
    
    func eulaGet(handler: @escaping (ResponseResult<EULAResponse>) -> Void) {
        
        let path = String(format: RouteRequests.eulaGet, Device.locale)
        guard let url = URL(string: path, relativeTo: RouteRequests.baseUrl) else {
            assertionFailure()
           return
        }
        
        sessionManager
            .request(url)
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    
                    guard let content = EULAResponse(json: JSON(data: data)) else {
                        assertionFailure()
                        let error = CustomErrors.serverError("failed parsing EULAResponse")
                        handler(.failed(error))
                        return
                    }
                    handler(.success(content))
                   
                case .failure(let error):
                    handler(.failed(CustomErrors.serverError("Failed request eulaGet, \(error.localizedDescription)")))
                }
        }
    }
}
