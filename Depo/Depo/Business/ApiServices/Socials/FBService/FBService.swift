//
//  FBService.swift
//  Depo
//
//  Created by Maksim Rahleev on 07/08/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import SwiftyJSON
import FBSDKLoginKit

public enum FBStatusValue: String {
    case pending = "PENDING"
    case running = "RUNNING"
    case failed = "FAILED"
    case waitingAction = "WAITING_ACTION"
    case scheduled = "SCHEDULED"
    case finished = "FINISHED"
    case cancelled = "CANCELLED"
    case none = ""
}

class FBService: BaseRequestService {
    func requestToken(permissions: [String], success: ((String) -> Void)?, fail: FailResponse?) {
        log.debug("FBService requestToken")

        let vc = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController!
        
        FBSDKLoginManager().logIn(withReadPermissions: permissions, from: vc) { result, error in
            if let error = error {
                fail?(.error(error))
            } else if let result = result {
                if result.isCancelled {
                    fail?(.string(TextConstants.NotLocalized.facebookLoginCanceled))
                } else {
                    success?(result.token.tokenString)
                }
            }
        }
    }
    
    func requestPermissions(success: SuccessResponse?, fail: FailResponse?) {
        log.debug("FBService requestPermissions")

        let fb = FBPermissions()
        let handler = BaseResponseHandler<FBPermissionsObject, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: fb, handler: handler)
    }
    
    func requestConnect(withToken token: String, success: SuccessResponse?, fail: FailResponse?) {
        log.debug("FBService requestConnect")

        let fb = FBConnect(withToken: token)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: fb, handler: handler)
    }
    
    func requestStatus(success: SuccessResponse?, fail: FailResponse?) {
        log.debug("FBService requestStatus")

        let fb = FBStatus()
        let handler = BaseResponseHandler<FBStatusObject, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: fb, handler: handler)
    }
    
    func requestStart(success: SuccessResponse?, fail: FailResponse?) {
        log.debug("FBService requestStart")

        let fb = FBStart()
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: fb, handler: handler)
    }
    
    func requestStop(success: SuccessResponse?, fail: FailResponse?) {
        log.debug("FBService requestStop")

        let fb = FBStop()
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: fb, handler: handler)
    }
}
