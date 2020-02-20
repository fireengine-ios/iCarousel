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
            var countryCode = ""
            prepareCountryCode { preparedCountryCode in
                countryCode = preparedCountryCode
                group.leave()
            }
            
            
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
                                             countryCode: countryCode)
                
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
        
        Netmera.start()
        
        #if DEBUG
        Netmera.setLogLevel(.debug)
        #endif
        
        #if LIFEBOX
        #if APPSTORE
        Netmera.setAPIKey("3PJRHrXDiqbDyulzKSM_m59cpbYT9LezJOwQ9zsHAkjMSBUVQ92OWw")
        #elseif  RELEASE
        Netmera.setAPIKey("3PJRHrXDiqa-pwWScAq1PwON_uN9F4h_7_vf0s3AwgwwqNTCnPZ_Bg")
        #elseif ENTERPRISE || DEBUG
        Netmera.setAPIKey("3PJRHrXDiqa-pwWScAq1P9AgrOteDDLvwaHjgjAt-Ohb1OnTxfy_8Q")
        #endif
        #endif
        
        
        #if LIFEDRIVE
        #if APPSTORE
        Netmera.setAPIKey("LINA4LCdpz44QTLXQBpw_aczLfB3nyWqit1C9oeYa1nzrgct0J5WOQ")
        #elseif ENTERPRISE || DEBUG
        Netmera.setAPIKey("6l30TJ05YeluVSpiY3Al8xcpW3mTkldj6_KWcwS8iNrRTgBKe1166A")
        #endif
        #endif

        
        Netmera.setAppGroupName(SharedConstants.groupIdentifier)
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
               autoLogin: "Null", turkcellPassword: "Null", buildNumber: "Null", countryCode: "Null")
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
           AccountService().usage(
               success: { response in
                   guard let usage = response as? UsageResponse,
                       let quotaBytes = usage.quotaBytes, quotaBytes != 0,
                       let usedBytes = usage.usedBytes else {
                           preparedUserField(0)
                           return
                   }
                   
                   let usagePercentage = CGFloat(usedBytes) / CGFloat(quotaBytes)
                   preparedUserField(Int(usagePercentage * 100))
                   
               }, fail: { errorResponse in
                   preparedUserField(0)
           })
       }
        
    private static func prepareCountryCode(preparedCountryCode: @escaping NetmeraFieldCallback) {
        AccountService().info(
            success: { response in
                guard let info = response as? AccountInfoResponse, let countryCode = info.countryCode else {
                    preparedCountryCode("Null")
                    return
                }
                preparedCountryCode(countryCode)
        }, fail: { errorResponse in
            preparedCountryCode("Null")
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

