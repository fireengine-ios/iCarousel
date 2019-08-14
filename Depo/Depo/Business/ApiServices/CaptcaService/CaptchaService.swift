//
//  CaptchaService.swift
//  Depo
//
//  Created by Alexander Gurin on 6/20/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

enum CaptchaType: String {
    case audio = "AUDIO"
    case image = "IMAGE"
}

struct CaptchaParametr: RequestParametrs {
    var timeout: TimeInterval {
        return NumericConstants.defaultTimeout
    }
    
    let uuid: String
    let type: String
    
    var requestParametrs: Any {
        let dict: [String: Any] = [:]
        return dict
    }
    
    var patch: URL {
        let patch_: String = String(format: RouteRequests.captcha, type, uuid)
        return URL(string: patch_, relativeTo: RouteRequests.baseUrl)!
    }
    
    var header: RequestHeaderParametrs {
        return [:]
    }
}

final class CaptchaSignUpRequrementService {
    let sessionManager: SessionManager
    
    init(sessionManager: SessionManager = SessionManager.customDefault) {
        self.sessionManager = sessionManager
    }
    
    public func getCaptchaRequrement(handler: @escaping ResponseBool) {
        guard let requestURL = URL(string: RouteRequests.captchaRequired, relativeTo: RouteRequests.baseUrl) else {
            handler(ResponseResult.failed(CustomErrors.unknown))
            return
        }
        sessionManager
            .request(requestURL)
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    guard let captchaSignUp = CaptchaSignUpRequirementResponse(json: JSON(data: data)) else {
                            handler(ResponseResult.failed(MappingError(data: data)))
                            return
                    }
                    handler(ResponseResult.success(captchaSignUp.captchaRequired))
                case .failure(let error):
                    
                    debugLog("HomeCardsService all response: \(response)")
                    debugLog("HomeCardsService all statusCode: \(response.response?.statusCode ?? -1111)")
                    
                    let backendError = ResponseParser.getBackendError(data: response.data,
                                                                      response: response.response)
                    handler(ResponseResult.failed(backendError ?? error))
                }
        }
    }
     
}

struct CaptchaSignUpRequrementParametr: RequestParametrs {
    var timeout: TimeInterval {
        return NumericConstants.defaultTimeout
    }
    
    var requestParametrs: Any = [String: Any]()
    
    var patch: URL {
        let patch_: String = String(format: RouteRequests.captchaRequired)
        return URL(string: patch_, relativeTo: RouteRequests.baseUrl)!
    }
    
    var header: RequestHeaderParametrs {
        return [:]
    }
    
}

struct CaptchaParametrAnswer: RequestParametrs {
    var timeout: TimeInterval {
        return NumericConstants.defaultTimeout
    }
    
    let uuid: String
    let answer: String
    
    var requestParametrs: Any {
        let dict: [String: Any] = [:]
        return dict
    }
    
    var patch: URL {
        let patch_: String = String(format: RouteRequests.captcha, answer, uuid)
        return URL(string: patch_, relativeTo: RouteRequests.baseUrl)!
    }
    
    var header: RequestHeaderParametrs {
        return RequestHeaders.captchaHeader(id: uuid, answer: answer)
    }
}

final class CaptchaResponse: ObjectRequestResponse {
    var data: Data?
    var type: CaptchaType? {
        if let htype: String = self.responseHeader?[HeaderConstant.ContentType] as? String {
            if htype.hasPrefix("image") {
                return .image
            }
            if htype.hasPrefix("audio") {
                return .audio
            }
        }
        return nil
    }
    
    required init(json: Data?, headerResponse: HTTPURLResponse?) {
        self.data = json
        super.init(json: nil, headerResponse: headerResponse)
    }
    
    required init(withJSON: JSON?) {
        debugLog("CaptchaResponse init(withJSON:) has not been implemented")
        fatalError("init(withJSON:) has not been implemented")
    }
}

final class CaptchaSignUpRequrementResponse: ObjectRequestResponse {
    
    var data: Data?
    var captchaRequired: Bool = false

    private let captchaRequiredJsonKey = "captchaRequired"
    
    required init(json: Data?, headerResponse: HTTPURLResponse?) {
        self.data = json
        super.init(json: json, headerResponse: headerResponse)
    }
    
    override func mapping() {
        captchaRequired = json?[captchaRequiredJsonKey].boolValue ?? false
    }
    
    required init(withJSON: JSON?) {
        super.init(withJSON: withJSON)
    }
}

final class CaptchaService: BaseRequestService {
    
    private(set) var uuid: String = UUID().uuidString
    
    func getCaptcha(uuid: String? = nil, type: CaptchaType = .image, sucess: SuccessResponse?, fail: FailResponse?) {
        debugLog("CaptchaService getCaptcha")
        
        if let uuid = uuid {
            self.uuid = uuid
        } else {
            self.uuid = UUID().uuidString
        }
        
        let param = CaptchaParametr(uuid: self.uuid, type: type.rawValue)
        let handler = BaseResponseHandler<CaptchaResponse, ObjectRequestResponse>(success: sucess, fail: fail, expectedDataFormat: .DataFormat)
        executeGetRequest(param: param, handler: handler)
    }
    
    func getSignUpCaptchaRequrement(sucess: SuccessResponse?, fail: FailResponse?) {
        let handler = BaseResponseHandler<CaptchaSignUpRequrementResponse, ObjectRequestResponse>(success: sucess, fail: fail, expectedDataFormat: .DataFormat)
        executeGetRequest(param: CaptchaSignUpRequrementParametr(), handler: handler)
    }
    
}
    
