//
//  InstagramService.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import Alamofire

final class InstagramService: BaseRequestService {
    
    let sessionManager: SessionManager
    
    init(sessionManager: SessionManager = SessionManager.customDefault) {
        self.sessionManager = sessionManager
    }
    
    func socialStatus(success: SuccessResponse?, fail: FailResponse?) {
        debugLog("InstagramService socialStatus")
        let params = SocialStatusParametrs()
        let handler = BaseResponseHandler<SocialStatusResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: params, handler: handler)
    }
    
    func getInstagramConfig(success: SuccessResponse?, fail: FailResponse?) {
        debugLog("InstagramService getInstagramConfig")

        let parameters = InstagramConfigParametrs()
        let handler = BaseResponseHandler<InstagramConfigResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: parameters, handler: handler)
    }
    
    func getSyncStatus(success: SuccessResponse?, fail: FailResponse?) {
        debugLog("InstagramService getSyncStatus")

        let parameters = SocialSyncStatusGetParametrs()
        let handler = BaseResponseHandler<SocialSyncStatusResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: parameters, handler: handler)
    }
    
    func setSyncStatus(param: SocialSyncStatusParametrs, success: SuccessResponse?, fail: FailResponse?) {
        debugLog("InstagramService setSyncStatus")

        let handler = BaseResponseHandler<SendSocialSyncStatusResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: param, handler: handler)
    }
    
    func createMigration(success: SuccessResponse?, fail: FailResponse?) {
        debugLog("InstagramService createMigration")

        let parameters = CreateMigrationParametrs()
        let handler = BaseResponseHandler<CreateMigrationResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: parameters, handler: handler)
    }
    
    func cancelMigration(success: SuccessResponse?, fail: FailResponse?) {
        debugLog("InstagramService cancelMigration")

        let parameters = CancelMigrationParametrs()
        let handler = BaseResponseHandler<CancelMigrationResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: parameters, handler: handler)
    }
    
    func checkInstagramLogin(instagramAccessToken: String, handler: @escaping (ResponseResult<Void>) -> Void) {
        sessionManager
            .request(RouteRequests.instagramConnect,
                     method: .post,
                     encoding: instagramAccessToken)
            .customValidate()
            .responseString { response in
                switch response.result {
                case .success(let answer):
                    if answer.contains("NOK") {
                        let error = CustomErrors.text(TextConstants.instagramNotConnected)
                        handler(.failed(error))
                        
                    } else if answer.contains("OK") {
                        handler(.success(()))
                        
                    } else {
                        assertionFailure("unexpected response")
                        let error = CustomErrors.text(TextConstants.instagramNotConnected)
                        handler(.failed(error))
                    }
                case .failure(let error):
                    handler(.failed(error))
                }
        }
    }
    
    func disconnectInstagram(handler: @escaping (ResponseResult<Void>) -> Void) {
        sessionManager
            .request(RouteRequests.instagramDisconnect,
                     method: .post)
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
//
//    func setSyncStatusAndCreateMigration(success: SuccessResponse?, fail: FailResponse?){
//
//        let params = SocialSyncStatusParametrs(status:true)
//        setSyncStatus(param: params, success: { objectFromRequestResponse in
//            self.createMigration(success: { objectFromRequestResponse in
//                success?(objectFromRequestResponse)
//            }, fail: { errorResponse in
//                fail?(errorResponse)
//            })
//        }) { errorResponse in
//            fail?(errorResponse)
//        }
//        //                    self.createMigration(success: { (ObjectFromRequestResponse) in
//        //                        successResponse?(ObjectFromRequestResponse)
//        //                    }, fail: { (ErrorResponse) in
//        //                        failResponse?(ErrorResponse)
//        //                    })
//    }
//
}
