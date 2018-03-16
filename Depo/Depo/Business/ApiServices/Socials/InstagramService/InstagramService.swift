//
//  InstagramService.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

final class InstagramService: BaseRequestService {
    
    func socialStatus(success: SuccessResponse?, fail: FailResponse?) {
        log.debug("InstagramService socialStatus")
        let params = SocialStatusParametrs()
        let handler = BaseResponseHandler<SocialStatusResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: params, handler: handler)
    }
    
    func getInstagramConfig(success: SuccessResponse?, fail: FailResponse?) {
        log.debug("InstagramService getInstagramConfig")

        let parameters = InstagramConfigParametrs()
        let handler = BaseResponseHandler<InstagramConfigResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: parameters, handler: handler)
    }
    
    func getSyncStatus(success: SuccessResponse?, fail: FailResponse?) {
        log.debug("InstagramService getSyncStatus")

        let parameters = SocialSyncStatusGetParametrs()
        let handler = BaseResponseHandler<SocialSyncStatusResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: parameters, handler: handler)
    }
    
    func setSyncStatus(param: SocialSyncStatusParametrs, success: SuccessResponse?, fail: FailResponse?) {
        log.debug("InstagramService setSyncStatus")

        let handler = BaseResponseHandler<SendSocialSyncStatusResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: param, handler: handler)
    }
    
    func createMigration(success: SuccessResponse?, fail: FailResponse?) {
        log.debug("InstagramService createMigration")

        let parameters = CreateMigrationParametrs()
        let handler = BaseResponseHandler<CreateMigrationResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: parameters, handler: handler)
    }
    
    func cancelMigration(success: SuccessResponse?, fail: FailResponse?) {
        log.debug("InstagramService cancelMigration")

        let parameters = CancelMigrationParametrs()
        let handler = BaseResponseHandler<CancelMigrationResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: parameters, handler: handler)
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
