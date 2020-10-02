//
//  NetmeraService.swift
//  Depo
//
//  Created by Alex on 12/30/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Netmera

final class NetmeraService {
    
    typealias NetmeraFieldCallback = (_ netmeraField: String) -> Void
    typealias NetmeraIntFieldCallback = (_ netmeraField: Int) -> Void
    typealias NetmeraAccountInfoCallback = (_ accountInfo: AccountInfoResponse?) -> Void
    
    static func updateUser() {
        
        let tokenStorage: TokenStorage = factory.resolve()
        let loginStatus = tokenStorage.accessToken != nil
        
        
        let deviceUsedStorage = 1 - Device.getFreeDiskSpaceInPercent
        
        if loginStatus {
            
            let group = DispatchGroup()
            
            var nemeraAnalysisLeft = ""
            group.enter()
            prepareUserAnalysisCount { analysisLeftText in
                nemeraAnalysisLeft = analysisLeftText
                group.leave()
            }
            
            var lifeboxStorage: Int = 0
            group.enter()
            prepareLifeBoxUsage { usage in
                lifeboxStorage = usage
                group.leave()
            }
            
            var firGrouping = ""
            group.enter()
            prepareFIRGrouping { firField in
                firGrouping = firField
                group.leave()
            }
            
            group.enter()
            var activeSubscriptionNames = [String]()
            prepareActiveSubscriptionNames { subscriptions in
                activeSubscriptionNames = subscriptions
                group.leave()
            }
            
            group.enter()
            var autoLogin = ""
            var turkcellPassword = ""
            prepareTurkcellLoginScurityFields { preparedAutoLogin, preparedTurkcellPassword in
                autoLogin = preparedAutoLogin
                turkcellPassword = preparedTurkcellPassword
                group.leave()
            }
            
            group.enter()
            var countryCode: String = "Null"
            var userName: Int = 0
            var userSurname: Int = 0
            var email: Int = 0
            var phoneNumber: Int = 0
            var address: Int = 0
            var birthday: Int = 0
            prepareAccountInfo(preparedAccountInfo: { info in
                guard let accountInfo = info else {
                    group.leave()
                    return
                }
                
                countryCode = accountInfo.countryCode ?? "Null"
                userName = (accountInfo.username ?? "").isEmpty ? 0 : 1
                userSurname = (accountInfo.surname ?? "").isEmpty ? 0 : 1
                email = (accountInfo.email ?? "").isEmpty ? 0 : 1
                phoneNumber = (accountInfo.phoneNumber ?? "").isEmpty ? 0 : 1
                address = (accountInfo.address ?? "").isEmpty ? 0 : 1
                birthday = (accountInfo.dob ?? "").isEmpty ? 0 : 1
                group.leave()
            })
            
            
            let twoFactorNetmeraStatus = getTwoFactorStatus()
            let autoSyncState = getAutoSyncStatus()
            let accountType = getAccountType()
            let photoVideoAutosyncStatus = getAutoSyncPhotoVideoStatus()
            let netmeraAutoSyncStatusPhoto = photoVideoAutosyncStatus.photo
            let netmeraAutoSyncStatusVideo = photoVideoAutosyncStatus.video
            let verifiedEmailStatus = getVerifiedEmailStatus()
            let buildNumber = getBuildNumber()
            
            
            
            
            group.notify(queue: DispatchQueue.global()) {
                let user = NetmeraCustomUser(deviceStorage: Int(deviceUsedStorage*100),
                                             photopickLeftAnalysis: nemeraAnalysisLeft,
                                             lifeboxStorage: lifeboxStorage,
                                             faceImageGrouping: firGrouping,
                                             accountType: accountType,
                                             twoFactorAuthentication: twoFactorNetmeraStatus,
                                             autosync: autoSyncState,
                                             emailVerification: verifiedEmailStatus,
                                             autosyncPhotos: netmeraAutoSyncStatusPhoto,
                                             autosyncVideos: netmeraAutoSyncStatusVideo,
                                             packages: activeSubscriptionNames,
                                             autoLogin: autoLogin,
                                             turkcellPassword: turkcellPassword,
                                             buildNumber: buildNumber,
                                             countryCode: countryCode,
                                             isUserName: userName,
                                             isUserSurname: userSurname,
                                             isEmail: email,
                                             isPhoneNumber: phoneNumber,
                                             isAddress: address,
                                             isBirthDay: birthday)
                
                user.userId = SingletonStorage.shared.accountInfo?.gapId ?? ""
                DispatchQueue.toMain {
                    Netmera.update(user)
                }
            }
        } else {
            logEmptyUser()
        }
    }
    
    static func startNetmera() {
        
        debugLog("Start Netmera")
        
        #if DEBUG
        if !DispatchQueue.isMainQueue || !Thread.isMainThread {
            assertionFailure("👉 CALL THIS FROM MAIN THREAD")
        }
        #endif
        
//        Netmera.start()
        
        #if DEBUG
        Netmera.setLogLevel(.debug)
        #endif
        
        updateAPIKey()
        
        Netmera.setAppGroupName(SharedConstants.groupIdentifier)
    }
    
    static func updateAPIKey() {
        Netmera.setAPIKey(getApiKey())
    }
    
    private static func getApiKey() -> String {
        #if LIFEBOX
        switch RouteRequests.currentServerEnvironment {
        case .production:
            return "3PJRHrXDiqa-pwWScAq1P-7ZjPWA5mWdKHyMpdBrYMFMU4XzrPkaoQ"
        case .preProduction, .test:
            return "3PJRHrXDiqakWjtB7quX9jhybzZjSWI4tfk7QNeg9wF6ZWP9p5QxPQ"
        }
        #endif
        
        #if LIFEDRIVE
        switch RouteRequests.currentServerEnvironment {
        case .production:
            return "LINA4LCdpz6st8QajRsXvZ3eUwV5ENwJTbzrhSufrxjRWv-pvzwmZw"
        case .preProduction, .test:
            return "6l30TJ05YenQKefUTBw81SZPwBa404aJoAhPAsmZEdyxLJVO90Q8Rw"
        }
        #endif
        
        return ""
    }
    
    static func sendEvent(event: NetmeraEvent) {
        Netmera.send(event)
    }
    
    typealias TypeToCountDictionary = [FileType: Int]
    static func getItemsTypeToCount(items: [BaseDataSourceItem]) -> TypeToCountDictionary {
        var typeToCount = TypeToCountDictionary()
        items.forEach { typeToCount[$0.fileType, default: 0] += 1 }
        return typeToCount
    }
}


//MARK: - User Field Preparetion
extension NetmeraService {
    //TODO: this method shall be removed, because in the improvment we should call user after we logged in.
    private static func logEmptyUser() {
        let user = NetmeraCustomUser(deviceStorage: 0, photopickLeftAnalysis: "Null", lifeboxStorage: 0, faceImageGrouping: "Null", accountType: "Null",
                                     twoFactorAuthentication: "Null", autosync: "Null", emailVerification: "Null",
                                     autosyncPhotos: "Null", autosyncVideos: "Null", packages: ["Null"],
                                     autoLogin: "Null", turkcellPassword: "Null", buildNumber: "Null", countryCode: "Null", isUserName: 0,
                                     isUserSurname: 0, isEmail: 0, isPhoneNumber: 0, isAddress: 0, isBirthDay: 0)
        user.userId = SingletonStorage.shared.accountInfo?.gapId ?? ""
        DispatchQueue.toMain {
            Netmera.update(user)
        }
    }
    
    private static func prepareUserAnalysisCount(preparedUserField: @escaping NetmeraFieldCallback) {
        let instapickService: InstapickService = factory.resolve()
        instapickService.getAnalyzesCount { analyzeResult in
            switch analyzeResult {
            case .success(let analysisCount):
                preparedUserField(analysisCount.isFree ? NetmeraEventValues.PhotopickUserAnalysisLeft.premium.text : NetmeraEventValues.PhotopickUserAnalysisLeft.regular(analysisLeft: analysisCount.left).text)
            case .failed(_):
                preparedUserField("Null")
            }
        }
    }
    
    private static func prepareLifeBoxUsage(preparedUserField: @escaping NetmeraIntFieldCallback) {
        SingletonStorage.shared.getLifeboxUsagePersentage { percentage in
            preparedUserField(percentage ?? 0)
        }
    }
    
    private static func prepareAccountInfo(preparedAccountInfo: @escaping NetmeraAccountInfoCallback) {
        AccountService().info(
            success: { response in
                guard let info = response as? AccountInfoResponse else {
                    preparedAccountInfo(nil)
                    return
                }
                preparedAccountInfo(info)
        }, fail: { errorResponse in
            preparedAccountInfo(nil)
        })
    }
    
    private static func prepareFIRGrouping(preparedUserField: @escaping NetmeraFieldCallback) {
        SingletonStorage.shared.getFaceImageSettingsStatus(success: { isEnabled in
            preparedUserField(isEnabled ? NetmeraEventValues.OnOffSettings.on.text : NetmeraEventValues.OnOffSettings.off.text)
        }, fail: { _ in
            preparedUserField("Null")
        })
    }
    
    private static func prepareActiveSubscriptionNames(preparedUserField: @escaping ([String])->Void) {
        var activeSubscriptionNames = [String]()
        SingletonStorage.shared.getActiveSubscriptionsList(success: { response in
            activeSubscriptionNames = SingletonStorage.shared.activeUserSubscriptionList.map {
                return ($0.subscriptionPlanName ?? "") + "|"
            }
            preparedUserField(activeSubscriptionNames)
        }, fail: { errorResponse in
            preparedUserField(activeSubscriptionNames)
        })
    }
    
    private static func prepareTurkcellLoginScurityFields(preparedUserField: @escaping (_ autoLogin: String, _ turkcellPassword: String)->Void) {
        AccountService().securitySettingsInfo(success: { response in
            guard let unwrapedSecurityResponse = response as? SecuritySettingsInfoResponse,
                let turkCellPasswordOn = unwrapedSecurityResponse.turkcellPasswordAuthEnabled,
                let turkCellAutoLogin = unwrapedSecurityResponse.mobileNetworkAuthEnabled else {
                    return
            }
            
            let acceptableAutoLogin = turkCellAutoLogin ? NetmeraEventValues.OnOffSettings.on.text : NetmeraEventValues.OnOffSettings.off.text
            let acceptableTurkcellPassword = turkCellPasswordOn ? NetmeraEventValues.OnOffSettings.on.text : NetmeraEventValues.OnOffSettings.off.text
            preparedUserField(acceptableAutoLogin, acceptableTurkcellPassword)
        }) { error in
            preparedUserField("Null", "Null")
        }
    }
    
    private static func getAccountType() -> String {
        switch AuthoritySingleton.shared.accountType {
        case .standart:
            return NetmeraEventValues.AccountType.standart.text
        case .middle:
            return NetmeraEventValues.AccountType.standartPlus.text
        case .premium:
            return NetmeraEventValues.AccountType.premium.text
        }
    }
    
    private static func getTwoFactorStatus() -> String {
        let isTwoFactorAuthEnabled = SingletonStorage.shared.isTwoFactorAuthEnabled ?? false
        return isTwoFactorAuthEnabled ? NetmeraEventValues.OnOffSettings.on.text : NetmeraEventValues.OnOffSettings.off.text
    }
    
    private static func getAutoSyncStatus() -> String {
        let autoSyncStorageSettings = AutoSyncDataStorage().settings
        let confirmedAutoSyncSettingsState = autoSyncStorageSettings.isAutoSyncEnabled && autoSyncStorageSettings.isAutosyncSettingsApplied
        return confirmedAutoSyncSettingsState ? NetmeraEventValues.OnOffSettings.on.text : NetmeraEventValues.OnOffSettings.off.text
    }
    
    private static func getAutoSyncPhotoVideoStatus() -> (photo: String, video: String) {
        let autoSyncStorageSettings = AutoSyncDataStorage().settings
        let confirmedAutoSyncSettingsState = autoSyncStorageSettings.isAutoSyncEnabled && autoSyncStorageSettings.isAutosyncSettingsApplied
        
        let netmeraAutoSyncStatusPhoto: String
        let netmeraAutoSyncStatusVideo: String
        if confirmedAutoSyncSettingsState {
            netmeraAutoSyncStatusPhoto = NetmeraEventValues.AutoSyncState.getState(autosyncSettings: autoSyncStorageSettings.photoSetting).text
            netmeraAutoSyncStatusVideo = NetmeraEventValues.AutoSyncState.getState(autosyncSettings: autoSyncStorageSettings.videoSetting).text
        } else {
            netmeraAutoSyncStatusPhoto = NetmeraEventValues.AutoSyncState.never.text
            netmeraAutoSyncStatusVideo = NetmeraEventValues.AutoSyncState.never.text
        }
        
        return (netmeraAutoSyncStatusPhoto, netmeraAutoSyncStatusVideo)
    }
    
    private static func getVerifiedEmailStatus() -> String {
        if let isMailVerified = SingletonStorage.shared.accountInfo?.emailVerified  {
            return isMailVerified ? NetmeraEventValues.EmailVerification.verified.text : NetmeraEventValues.EmailVerification.notVerified.text
        } else {
            return "Null"
        }
    }
    
    private static func getBuildNumber() -> String {
        return (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "Null"
    }
    
}

