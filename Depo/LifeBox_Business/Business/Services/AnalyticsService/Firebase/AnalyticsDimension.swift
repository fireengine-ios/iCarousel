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
    let countOfUploadMetric: Int?
    let countOfDownloadMetric: Int?
    let gsmOperatorType: String
    let deviceId: String = Device.deviceId ?? ""
    let loginType: GADementionValues.login?
    let errorType: String?
    
    let isTwoFactorAuthEnabled: Bool?
    
    let dailyDrawleft: Int?
    let totalDraw: Int?
    
    let itemsOperationCount: GADementionValues.ItemsOperationCount?
    
    let editFields: String?
    
    let connectionStatus: Bool?
    let statusType: String?
    
    let usagePercentage: Int?
    
    let photoEditFilterType: String?
    
    let shareParameters: [String: Any]?
    
    var productParametrs: [String: Any] {
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
        if let isTwoFactorAuthEnabled = isTwoFactorAuthEnabled {
            dimesionDictionary[GADementionsFields.twoFactorAuth.text] = isTwoFactorAuthEnabled ? "True" : "False"
        }
        if let dailyDrawleft = dailyDrawleft {
            dimesionDictionary[GADementionsFields.dailyDrawleft.text] = dailyDrawleft
        }
        if let totalDraw = totalDraw {
            dimesionDictionary[GAMetrics.totalDraw.text] = totalDraw
        }
        if let itemsOperation = itemsOperationCount {
            dimesionDictionary[GADementionsFields.itemsCount(itemsOperation.operationType).text] = itemsOperation.count
        }
        if let editFields = editFields {
            dimesionDictionary[GADementionsFields.editFields.text] = editFields
        }
        if let connectionStatus = connectionStatus {
            dimesionDictionary[GADementionsFields.connectionStatus.text] = connectionStatus ? "Connected" : "Disconnected"
        }
        if let statusType = statusType {
            dimesionDictionary[GADementionsFields.statusType.text] = statusType
        }
        if let usagePercentage = usagePercentage {
            dimesionDictionary[GADementionsFields.usagePercentage.text] = usagePercentage
        }
        if let photoEditFilterType = photoEditFilterType {
            dimesionDictionary[GADementionsFields.photoEditFilterType.text] = photoEditFilterType
        }
        if let shareParameters = shareParameters {
            shareParameters.forEach { dimesionDictionary[$0.key] = $0.value }
        }
        return dimesionDictionary
    }
}
