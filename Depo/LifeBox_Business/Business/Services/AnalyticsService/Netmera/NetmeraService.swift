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
            
            var lifeboxStorage: Int = 0
            group.enter()
            prepareLifeBoxUsage { usage in
                lifeboxStorage = usage
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
            var regionCode: String = "Null"
            var userName: Int = 0
            var userSurname: Int = 0
            var email: Int = 0
            var phoneNumber: Int = 0
            var address: Int = 0
            var birthday: Int = 0
            var gapID = ""
            prepareAccountInfo(preparedAccountInfo: { info in
                guard let accountInfo = info else {
                    group.leave()
                    return
                }
                
                regionCode = accountInfo.msisdnRegion ?? "Null"
                countryCode = accountInfo.countryCode ?? "Null"
                userName = (accountInfo.username ?? "").isEmpty ? 0 : 1
                userSurname = (accountInfo.surname ?? "").isEmpty ? 0 : 1
                email = (accountInfo.email ?? "").isEmpty ? 0 : 1
                phoneNumber = (accountInfo.phoneNumber ?? "").isEmpty ? 0 : 1
                address = (accountInfo.address ?? "").isEmpty ? 0 : 1
                birthday = (accountInfo.dob ?? "").isEmpty ? 0 : 1
                gapID = accountInfo.gapId ?? ""
                group.leave()
            })
            
            
            let twoFactorNetmeraStatus = getTwoFactorStatus()
            let accountType = getAccountType()
            let verifiedEmailStatus = getVerifiedEmailStatus()
            let buildNumber = getBuildNumber()
            let galleryAccessPermission = LocalMediaStorage.default.galleryPermission.analyticsValue
            
            
            
            group.notify(queue: DispatchQueue.global()) {
                let user = NetmeraCustomUser(deviceStorage: Int(deviceUsedStorage*100),
                                             lifeboxStorage: lifeboxStorage,
                                             accountType: accountType,
                                             twoFactorAuthentication: twoFactorNetmeraStatus,
                                             emailVerification: verifiedEmailStatus,
                                             autoLogin: autoLogin,
                                             turkcellPassword: turkcellPassword,
                                             buildNumber: buildNumber,
                                             countryCode: countryCode,
                                             regionCode: regionCode,
                                             isUserName: userName,
                                             isUserSurname: userSurname,
                                             isEmail: email,
                                             isPhoneNumber: phoneNumber,
                                             isAddress: address,
                                             isBirthDay: birthday,
                                             galleryAccessPermission: galleryAccessPermission)
                
                user.userId = gapID
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
        
        updateAPIKey()
        
        Netmera.setAppGroupName(SharedConstants.groupIdentifier)
    }
    
    static func updateAPIKey() {
        Netmera.setAPIKey(getApiKey())
    }
    
    private static func getApiKey() -> String {
        //Sinnce its business only, no need for "def LIFEBOX" flag here
        switch RouteRequests.currentServerEnvironment {
        case .production:
            return "3PJRHrXDiqYtcLEQL75khlt-cZcy-Hmi68v5aHvOY13RrL4993gmXFx3xyEY3IEA"
        case .preProduction, .test:
            return "3PJRHrXDiqYtcLEQL75khhE-sJMri_nBxpaFKNoTZt76h75AzELaerJ1y92ip8oN"
        }
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
        let user = NetmeraCustomUser(deviceStorage: 0, lifeboxStorage: 0, accountType: "Null",
                                     twoFactorAuthentication: "Null", emailVerification: "Null",
                                     autoLogin: "Null", turkcellPassword: "Null", buildNumber: "Null", countryCode: "Null", regionCode: "Null", isUserName: 0,
                                     isUserSurname: 0, isEmail: 0, isPhoneNumber: 0, isAddress: 0, isBirthDay: 0, galleryAccessPermission: "Null")
        user.userId = SingletonStorage.shared.accountInfo?.gapId ?? ""
        DispatchQueue.toMain {
            Netmera.update(user)
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

