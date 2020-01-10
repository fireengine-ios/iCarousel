//
//  NetmeraService.swift
//  Depo
//
//  Created by Alex on 12/30/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Netmera

enum NetmeraEvents {
    enum Actions {
    }
    enum Screens {
    }
}

final class NetmeraService {
 
    static func updateUser() {
        let user = NetmeraUser()
        user.userId = SingletonStorage.shared.accountInfo?.gapId ?? ""
        
//        NetmeraUser *user = [[NetmeraUser alloc] init];
//        }}{{  user.autosync = @"On";
//        autosyncPhotos: Never/Wifi/Wifi_LTE
//        autosyncVideos: Never/Wifi/Wifi_LTE
//        deviceStorage:{used_percentage_value} : It shows how many storage used on the device.
//        lifeboxStorage:{used_percentage_value} : Settings/Account Detail/ My Storage
//        faceImageGrouping: On/Off
//        photopickLeftAnalysis:{count_of_left_analysis} : If user is premium, the value should be 'Free'.
//        accountType: Standard/Standard+/Premium : Settings/Account Detail/ Account Type
//        twoFactorAuthentication: On/Off
//        emailVerification: Verified/NotVerified
//

        
        
        Netmera.update(user)
    }
    
    static func startNetmera() {
        #if LIFEDRIVE
        return
        #endif
        
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
        
        #if APPSTORE
        Netmera.setAPIKey("3PJRHrXDiqbDyulzKSM_m59cpbYT9LezJOwQ9zsHAkjMSBUVQ92OWw")
        #elseif ENTERPRISE || DEBUG
        Netmera.setAPIKey("3PJRHrXDiqa-pwWScAq1P9AgrOteDDLvwaHjgjAt-Ohb1OnTxfy_8Q")
        #endif
        
        Netmera.setAppGroupName(SharedConstants.groupIdentifier)
    }
    
    static func sendEvent(event: NetmeraEvent) {
        Netmera.send(event)
    }
}

