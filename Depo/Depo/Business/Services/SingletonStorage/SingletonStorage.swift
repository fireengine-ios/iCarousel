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
    var faceImageSettings: SettingsInfoPermissionsResponse?
    var signUpInfo: RegistrationUserInfoModel?
    var activeUserSubscription: ActiveSubscriptionResponse?
    var referenceToken: String?
    var quotaInfoResponse: QuotaInfoResponse?
    var quotaUsage: Int?
    var progressDelegates = MulticastDelegate<OperationProgressServiceDelegate>()
    
    var isTwoFactorAuthEnabled: Bool?
    
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
            AccountService().info(success: { [weak self] accountInfoResponse in
                if let resp = accountInfoResponse as? AccountInfoResponse {
                    self?.accountInfo = resp
                    
                    self?.resumableUploadInfoService.updateInfo {
                        ///remove user photo from cache on start application
                        ImageDownloder.removeImageFromCache(url: resp.urlForPhoto, completion: {
                            DispatchQueue.toMain {
                                success(resp)
                            }
                        })
                    }
                } else {
                    DispatchQueue.toMain {
                        fail(ErrorResponse.string(TextConstants.errorServer))
                    }
                }
            }, fail: { error in
                DispatchQueue.toMain {
                    fail(error)
                }
            })
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
        return accountInfo?.isTurkcellUser ?? false
    }
    
    var isUserFromTurkey: Bool {
        return accountInfo?.isUserFromTurkey ?? false
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
                guard let subscriptionsResponse = response as? ActiveSubscriptionResponse else { return }
                self?.activeUserSubscription = subscriptionsResponse
                success(subscriptionsResponse)
            }, fail: { errorResponse in
                fail(errorResponse)
        })
    }
    
    var activeUserSubscriptionList: [SubscriptionPlanBaseResponse] {
        return activeUserSubscription?.list ?? []
    }
}
