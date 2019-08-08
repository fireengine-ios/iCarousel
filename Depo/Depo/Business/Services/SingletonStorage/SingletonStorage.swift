//
//  SingletonStorage.swift
//  Depo
//
//  Created by Oleg on 01.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class SingletonStorage {
    
    static let shared = SingletonStorage()
    
    var isAppraterInited: Bool = false
    var accountInfo: AccountInfoResponse?
    var faceImageSettings: SettingsInfoPermissionsResponse?
    var signUpInfo: RegistrationUserInfoModel?
    var activeUserSubscription: ActiveSubscriptionResponse?
    var referenceToken: String?
    var progressDelegates = MulticastDelegate<OperationProgressServiceDelegate>()
    
    var isJustRegistered: Bool?
    
    func getAccountInfoForUser(forceReload: Bool = false, success:@escaping (AccountInfoResponse) -> Void, fail: @escaping FailResponse ) {
        if let info = accountInfo, !forceReload {
            success(info)
        } else {
            AccountService().info(success: { accountInfoResponce in
                if let resp = accountInfoResponce as? AccountInfoResponse {
                    self.accountInfo = resp
                    ///remove user photo from cache on start application
                    ImageDownloder().removeImageFromCache(url: resp.urlForPhoto, completion: {
                        DispatchQueue.toMain {
                            success(resp)
                        }
                    })
                } else {
                    DispatchQueue.toMain {
                        fail(ErrorResponse.string(TextConstants.errorServer))
                    }
                }
            }) { error in
                DispatchQueue.toMain {
                    fail(error)
                }
            }
        }
    }
    
    var isTurkcellUser: Bool {
        return accountInfo?.accountType == "TURKCELL"
    }
    
    var uniqueUserID: String {
        return accountInfo?.projectID ?? ""
    }
    
    func getUniqueUserID(success:@escaping ((_ unigueUserID: String) -> Void), fail: @escaping FailResponse) {
        if !uniqueUserID.isEmpty {
            success(uniqueUserID)
            return
        }
        
        getAccountInfoForUser(success: { info in
            success(info.projectID ?? "")
        }, fail: fail)
    }
    
    private func getFaceImageRecognitionSettingsForUser(completion: @escaping (_ result: SettingsInfoPermissionsResponse) -> Void, fail: @escaping (ErrorResponse) -> Void) {
        if let unwrapedFIRStatus = faceImageSettings {
            completion(unwrapedFIRStatus)
            return
        }
        let accountService = AccountService()
        accountService.getSettingsInfoPermissions(handler: { [weak self] response in
            switch response {
            case .success(let result):
                self?.faceImageSettings = result
                completion(result)
            case .failed(let error):
                fail(ErrorResponse.string(error.description))
            }
        })
    }
    
    func getFaceImageSettingsStatus(success: @escaping (_ result: Bool) -> Void,
                                     fail: @escaping (ErrorResponse) -> Void,
                                     foreceReload: Bool = false) {
        guard foreceReload || faceImageSettings == nil,
        accountInfo != nil else {
            if let faceImageSettingsUnwraped  = faceImageSettings {
                success(faceImageSettingsUnwraped.isFaceImageAllowed ?? false)
            } else {
                fail(.string(TextConstants.errorUnknown))
            }
            return
        }
        getFaceImageRecognitionSettingsForUser(completion: { firStatus in
            guard let status = firStatus.isFaceImageAllowed else {
                fail(ErrorResponse.string(TextConstants.errorUnknown))
                return
            }
            success(status)
        }, fail: fail)
    }
    
    //MARK: - subscriptions
    
    func getActiveSubscriptionsList(success: @escaping (_ result: ActiveSubscriptionResponse) -> Void,
                                    fail: @escaping (ErrorResponse) -> Void,
                                    foreceReload: Bool = false) {
        
        guard foreceReload || activeUserSubscription == nil,
            accountInfo != nil else {
            if let activeSubsUnwraped  = activeUserSubscription {
                success(activeSubsUnwraped)
            } else {
                fail(.string(TextConstants.errorUnknown))
            }
            return
        }
        SubscriptionsServiceIml().activeSubscriptions(
            success: { [weak self] response in
                guard let subscriptionsResponce = response as? ActiveSubscriptionResponse else { return }
                self?.activeUserSubscription = subscriptionsResponce
                success(subscriptionsResponce)
            }, fail: { errorResponse in
                fail(errorResponse)
        })
    }
    
    var activeUserSubscriptionList: [SubscriptionPlanBaseResponse] {
        return activeUserSubscription?.list ?? []
    }
}
