//
//  SingletonStorage.swift
//  Depo
//
//  Created by Oleg on 01.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

typealias UsagePercenatageCallback = (Int?) -> Void

class SingletonStorage {
    
    static let shared = SingletonStorage()
    
    var isAppraterInited: Bool = false
    var accountInfo: AccountInfoResponse?
    var featuresInfo: FeaturesResponse?
    var faceImageSettings: SettingsInfoPermissionsResponse?
    var signUpInfo: RegistrationUserInfoModel?
    var referenceToken: String?
    var quotaInfoResponse: QuotaInfoResponse?
    var quotaUsage: Int?
    var progressDelegates = MulticastDelegate<OperationProgressServiceDelegate>()
    
    var isTwoFactorAuthEnabled: Bool?
    
    var isUserAdmin: Bool {
        return accountInfo?.parentAccountAdmin ?? false
    }
    
    private let resumableUploadInfoService: ResumableUploadInfoService = factory.resolve()
    
    private static let isEmailVerificationCodeSentKey = "isEmailVerificationCodeSentKeyFor\(SingletonStorage.shared.uniqueUserID)"
    var isEmailVerificationCodeSent: Bool {
        set { UserDefaults.standard.set(newValue, forKey: SingletonStorage.isEmailVerificationCodeSentKey) }
        get { return UserDefaults.standard.value(forKey: SingletonStorage.isEmailVerificationCodeSentKey) as? Bool ?? false }
    }

    var isJustRegistered: Bool?

    var isNeedToSentEmailVerificationCode: Bool {
        AuthoritySingleton.shared.checkNewVersionApp()
        
        let isNewAppVersion = AuthoritySingleton.shared.isNewAppVersion
        let isUserJustRegistered = (isJustRegistered == true)
        
        ///send code if:
        /// - new app version
        /// - first manual login after sign up
        ///
        /// such sentence is needed fo avoid code sending after sign up with fresh app installing and immediately code sending
        return (isNewAppVersion || !isEmailVerificationCodeSent) && !isUserJustRegistered
    }
    
    func logoutClear() {
        accountInfo = nil
        isJustRegistered = nil
        quotaInfoResponse = nil
        quotaUsage = nil
    }
    
    func getAccountInfoForUser(forceReload: Bool = false, success:@escaping (AccountInfoResponse) -> Void, fail: @escaping FailResponse ) {
        if let info = accountInfo, !forceReload {
            success(info)
        } else {
            AccountService().info { [weak self] response in
                switch response {
                    case .success(let accountInfo):
                        self?.accountInfo = accountInfo
                        
                        self?.resumableUploadInfoService.updateInfo { [weak self] featuresInfo in
                            self?.featuresInfo = featuresInfo
                            ///remove user photo from cache on start application
                            ImageDownloder.removeImageFromCache(url: accountInfo.profilePhoto, completion: {
                                DispatchQueue.toMain {
                                    success(accountInfo)
                                }
                            })
                        }
                        
                    case .failed(let error):
                        DispatchQueue.toMain {
                            fail(ErrorResponse.error(error))
                        }
                }
            }
        }
    }

    func getStorageUsageInfo(projectId: String, userAccountId: String, success:@escaping (SettingsStorageUsageResponseItem) -> Void, fail: @escaping FailResponse) {
        AccountService().storageUsageInfo(projectId: projectId, accoundId: userAccountId) { [weak self] response in
                switch response {
                    case .success(let usageInfo):
                        DispatchQueue.toMain {
                            success(usageInfo)
                        }
                    case .failed(let error):
                        DispatchQueue.toMain {
                            fail(ErrorResponse.error(error))
                        }
                }
        }

    }
    
    var isTurkcellUser: Bool {
        return true
    }
    
    var isUserFromTurkey: Bool {
        return true
    }
    
    var uniqueUserID: String {
        return accountInfo?.uuid ?? ""
    }
    
    func getUniqueUserID(success:@escaping ((_ unigueUserID: String) -> Void), fail: @escaping FailResponse) {
        if !uniqueUserID.isEmpty {
            success(uniqueUserID)
            return
        }
        
        getAccountInfoForUser(success: { info in
            success(info.uuid)
        }, fail: fail)
    }
}
