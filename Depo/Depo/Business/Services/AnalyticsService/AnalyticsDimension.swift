//
//  AnalyticsDementsonObject.swift
//  Depo
//
//  Created by Aleksandr on 8/4/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

struct AnalyticsDimension {
    let screenName: Any//String
    let pageType: Any//used to be AnalyticsAppScreens, now just string
    let sourceType: Any//String
    let loginStatus: String
    let platform: String
    let isWifi: Bool
    let service: String
    let developmentVersion: String
    let paymentMethod: String? //Should be sent after package purchase. Value is Turkcell or inApp
    let userId: Any
    let operatorSystem: Any//should be String if everything ok
    let facialRecognition: Any//not bool in case of Null
    let userPackagesNames: [String] //Pacakage names that the user owns should be sent with every page click. Pacakage names should be seperated with pipe "|"
    let countOfUploadMetric: Int?
    let countOfDownloadMetric: Int?
    let gsmOperatorType: String
    let deviceId: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
    let loginType: GADementionValues.login?
    let errorType: String?
    
    let autoSyncState: String?
    let autoSyncStatus: [String: Any]?
    
    var productParametrs: [String: Any] {
        var userOwnedPackages = ""
        userPackagesNames.forEach {
            if !userOwnedPackages.isEmpty {
                userOwnedPackages.append("|") ///either that or just make userOwnedPackages.append("|\($0)")
            }
            userOwnedPackages.append("\($0)")
        }
        var dimesionDictionary: [String: Any] = [
            GADementionsFields.screenName.text : screenName,
            GADementionsFields.pageType.text : pageType,//.name,
            GADementionsFields.sourceType.text : sourceType,
            GADementionsFields.loginStatus.text : loginStatus,
            GADementionsFields.platform.text : platform,
            GADementionsFields.networkFixWifi.text : isWifi ? "True" : "False",
            ///index54=isWifi:  is sent as “TRUE". It should be “True”. Only first letter should be capital.
            GADementionsFields.service.text : service,
            GADementionsFields.developmentVersion.text : developmentVersion,
            GADementionsFields.userID.text : userId,
            GADementionsFields.operatorSystem.text : operatorSystem,
            GADementionsFields.faceImageStatus.text : "\(facialRecognition)",
            GADementionsFields.userPackage.text : userOwnedPackages,
            GADementionsFields.gsmOperatorType.text : gsmOperatorType,
            GADementionsFields.deviceId.text: deviceId
        ]
        if let paymentMethodUnwraped = paymentMethod {
            dimesionDictionary[GADementionsFields.paymentMethod.text] = paymentMethodUnwraped
        }
        if let numberOfDownloads = countOfDownloadMetric {
            dimesionDictionary[GAMetrics.countOfDownload.text] = "\(numberOfDownloads)"
        }
        if let numberOfUploads = countOfUploadMetric {
            dimesionDictionary[GAMetrics.countOfUpload.text] = "\(numberOfUploads)"
        }
        if let loginType = loginType {
            dimesionDictionary[GADementionsFields.loginType.text] = loginType.text
        }
        if let errorType = errorType {
            dimesionDictionary[GADementionsFields.errorType.text] = errorType
        }
        if let autoSyncState = autoSyncState {
            dimesionDictionary[GADementionsFields.autoSyncState.text] = autoSyncState
        }
        if let autoSyncStatus = autoSyncStatus {
            dimesionDictionary[GADementionsFields.autoSyncStatus.text] = prepareAutoSyncSettings(autoSyncSettings: autoSyncStatus)
        }
        
        return dimesionDictionary
    }
    
    private func prepareAutoSyncSettings(autoSyncSettings: [String: Any]) -> String {
        var combinedStatus = ""
//        SyncStatus --> Photos - Never / Photos - Wifi / Photos - Wifi&LTE / Videos - Never / Videos - Wifi / Videos - Wifi&LTE

        if let photoMobileStatus = autoSyncSettings[AutoSyncSettings.SettingsKeys.mobileDataPhotosKey] as? Bool,
            let photoWifiStatus = autoSyncSettings[AutoSyncSettings.SettingsKeys.wifiPhotosKey] as? Bool
            {
                if !photoWifiStatus, !photoMobileStatus {
                    combinedStatus += "Photos - Never /"
                } else if photoMobileStatus {
                    combinedStatus += "Photos - Wifi&LTE /"
                } else if photoWifiStatus {
                    combinedStatus += "Photos - Wifi /"
                }
        } else {
            combinedStatus += "Photos - Never /"
        }
        
        if let videoMobileStatus = autoSyncSettings[AutoSyncSettings.SettingsKeys.mobileDataVideoKey] as? Bool,
            let videoWifiStatus = autoSyncSettings[AutoSyncSettings.SettingsKeys.wifiVideoKey] as? Bool
        {
            if !videoMobileStatus, !videoWifiStatus {
                combinedStatus += "Videos - Never /"
            } else if videoMobileStatus {
                combinedStatus += "Videos - Wifi&LTE /"
            } else if videoWifiStatus {
                combinedStatus += "Videos - Wifi /"
            }
        } else {
            combinedStatus += "Videos - Never"
        }
        
        return combinedStatus
    }
    
}
