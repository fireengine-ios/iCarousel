//
//  CaptchaService.swift
//  Depo
//
//  Created by Alexander Gurin on 6/20/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import SwiftyJSON

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


final class CaptchaService: BaseRequestService {
    
    private(set) var uuid: String = UUID().uuidString
    
    func getCaptcha(uuid: String? = nil, type: CaptchaType = .image, sucess: SuccessResponse?, fail: FailResponse?   ) {
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
    
}
    
