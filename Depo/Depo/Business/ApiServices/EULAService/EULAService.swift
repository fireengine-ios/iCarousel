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
        let path = String(format: RouteRequests.eulaGet, Device.locale)
        guard let url = URL(string: path, relativeTo: RouteRequests.baseUrl) else {
            assertionFailure()
           return 
        }
        return url
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

struct EULAApprove: RequestParametrs {
    var timeout: TimeInterval {
        return NumericConstants.defaultTimeout
    }
    
    let id: Int
    let etkAuth: Bool?
    
    var requestParametrs: Any {
        var params: [String: Any] = [LbRequestkeys.eulaId: id]
        if let etkAuth = etkAuth {
            params[LbRequestkeys.etkAuth] = etkAuth
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

    func eulaApprove(eulaId: Int, etkAuth: Bool?, sucess: SuccessResponse?, fail: FailResponse? ) {
        debugLog("EulaService eulaApprove")
        
        let eula = EULAApprove(id: eulaId, etkAuth: etkAuth)
        
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: sucess, fail: fail)
        executePostRequest(param: eula, handler: handler)

    }
    
    private let sessionManager: SessionManager = factory.resolve()
    
    func getEtkAuth(for phoneNumber: String?, handler: @escaping ResponseBool) {
        debugLog("EulaService getEtkAuth")
        
        let params: Parameters?
        if let phoneNumber = phoneNumber {
            params = ["phoneNumber": phoneNumber]
        } else {
            params = [:]
        }
        
        sessionManager
            .request(RouteRequests.eulaGetEtkAuth,
                     method: .post,
                     parameters: params,
                     encoding: JSONEncoding.prettyPrinted)
            .customValidate()
            .responseString { response in
                switch response.result {
                case .success(let text):
                    if let isShowEtk = Bool(string: text) {
                        handler(.success(isShowEtk))
                    } else {
                        let error = CustomErrors.serverError(text)
                        handler(.failed(error))
                    }
                case .failure(let error):
                    handler(.failed(error))
                }
        }
    }
    
    
    func getTermOfUse(handler: @escaping (ResponseResult<TermsEULAResponse>) -> Void) {
        
        let path = String(format: RouteRequests.eulaGetTerms, Device.locale)
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
                    guard let content = TermsEULAResponse(json: JSON(data: data)) else {
                        assertionFailure()
                        let error = CustomErrors.serverError("failed parsing TermsEULAResponse")
                        handler(.failed(error))
                        return
                    }
                    handler(.success(content))
                   
                case .failure(let error):
                    handler(.failed(CustomErrors.serverError("Failed request getTermOfUse, \(error.localizedDescription)")))
                }
        }
    }
}
