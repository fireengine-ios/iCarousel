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
import Alamofire

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
        debugLog("FBService requestToken")

        let vc = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController!

        let fbManager = LoginManager()
        fbManager.logOut()
        fbManager.logIn(permissions: permissions, from: vc) { result, error in
            if let error = error {
                fail?(.error(error))
            } else if let result = result {
                if result.isCancelled {
                    fail?(.string(TextConstants.NotLocalized.facebookLoginCanceled))
                } else if let token = result.token?.tokenString {
                    success?(token)
                } else {
                    fail?(.string(TextConstants.NotLocalized.facebookLoginFailed))
                }
            }
        }
    }
    
    func requestPermissions(success: SuccessResponse?, fail: FailResponse?) {
        debugLog("FBService requestPermissions")

        let fb = FBPermissions()
        let handler = BaseResponseHandler<FBPermissionsObject, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: fb, handler: handler)
    }
    
    func requestConnect(withToken token: String, success: SuccessResponse?, fail: FailResponse?) {
        debugLog("FBService requestConnect")

        let fb = FBConnect(withToken: token)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: fb, handler: handler)
    }
    
    func socialStatus(success: SuccessResponse?, fail: FailResponse?) {
        debugLog("FBService socialStatus")
        let params = SocialStatusParametrs()
        let handler = BaseResponseHandler<SocialStatusResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: params, handler: handler)
    }
    
    func requestStatus(success: SuccessResponse?, fail: FailResponse?) {
        debugLog("FBService requestStatus")

        let fb = FBStatus()
        let handler = BaseResponseHandler<FBStatusObject, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: fb, handler: handler)
    }
    
    func requestStart(success: SuccessResponse?, fail: FailResponse?) {
        debugLog("FBService requestStart")

        let fb = FBStart()
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: fb, handler: handler)
    }
    
    func requestStop(success: SuccessResponse?, fail: FailResponse?) {
        debugLog("FBService requestStop")

        let fb = FBStop()
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: fb, handler: handler)
    }
    
    private lazy var sessionManager: SessionManager = factory.resolve()
    
    func requestStatus(handler: @escaping ResponseBool) {
        let url = RouteRequests.baseUrl +/ RouteRequests.fbStatus
        sessionManager
            .request(url)
            .customValidate()
            .responseData { response in
                switch response.result {    
                case .success(let data):
                    
                    let fbStatus = FBStatusObject(json: data, headerResponse: nil)
                    
                    guard let isConnected = fbStatus.connected, let isSyncEnabled = fbStatus.syncEnabled else {
                        let debugText = String(data: data, encoding: .utf8) ?? String(data.count)
                        let error = CustomErrors.serverError(debugText)
                        handler(.failed(error))
                        return
                    }
                    
                    if isConnected, isSyncEnabled {
                        handler(.success(true))
                    } else {
                        handler(.success(false))
                    }
                case .failure(let error):
                    handler(.failed(error))
                }
        }
    }
    
    func disconnectFacebook(handler: @escaping (ResponseResult<Void>) -> Void) {
        sessionManager
            .request(RouteRequests.fbDisconnect,
                     method: .delete)
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(_):
                    handler(.success(()))
                case .failure(let error):
                    handler(.failed(error))
                }
        }
    }
}
