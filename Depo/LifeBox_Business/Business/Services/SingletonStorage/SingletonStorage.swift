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
    
    func getOverQuotaStatus(completion: @escaping VoidHandler) {
        let storageVars: StorageVars = factory.resolve()
        
        ///to send initial value as true
        let showPopUp =  !storageVars.largeFullOfQuotaPopUpCheckBox
        
        AccountService().overQuotaStatus(with: showPopUp, success: { response in
            guard let response = response as? OverQuotaStatusResponse, let value = response.value else {
                completion()
                return
            }
            
            switch value {
            case .nonOverQuota:
                storageVars.largeFullOfQuotaPopUpShowType100 = false
            case .overQuotaFreemium:
                storageVars.largeFullOfQuotaPopUpShowType100 = true
                storageVars.largeFullOfQuotaUserPremium = false
            case .overQuotaPremium:
                storageVars.largeFullOfQuotaPopUpShowType100 = true
                storageVars.largeFullOfQuotaUserPremium = true
            }
            
            completion()
            
            }, fail: { error in
               assertionFailure("Тo data received for overQuotaStatus request \(error.localizedDescription) ")
               completion()
        })
    }
    
    func getLifeboxUsagePersentage(usagePercentageCallback: @escaping UsagePercenatageCallback) {
        guard quotaUsage == nil else {
            usagePercentageCallback(quotaUsage)
            return
        }
        
        prepareLifeBoxUsage { [weak self] percentage in
            guard let persentage = percentage else {
                usagePercentageCallback(nil)
                return
            }
            self?.quotaUsage = persentage
            usagePercentageCallback(percentage)
        }
        
    }
    
    private func prepareLifeBoxUsage(preparedUserField: @escaping UsagePercenatageCallback) {
        AccountService().quotaInfo(
            success: { [weak self] response in
                guard let quota = response as? QuotaInfoResponse,
                    let quotaBytes = quota.bytes, quotaBytes != 0,
                    let usedBytes = quota.bytesUsed else {
                        preparedUserField(0)
                        return
                }
                self?.quotaInfoResponse = quota
                let usagePercentage = CGFloat(usedBytes) / CGFloat(quotaBytes)
                preparedUserField(Int(usagePercentage * 100))
                
        }, fail: { [weak self] errorResponse in
            self?.quotaInfoResponse = nil
            preparedUserField(nil)
        })
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
