//
//  AnalyticsDementsonObject.swift
//  Depo
//
//  Created by Aleksandr on 8/4/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

//Analytics.logEvent("screenView", parameters: [
//    "screenName": “Name of the Screen is put here”
//    "pageType": “HomePage”
//    "sourceType": “Music”
//    ])
//    ...
//"countOfUpload": “15”
//...

struct AnalyticsDementsonObject {
    let screenName: String
    let pageType: AnalyticsAppScreens
    let sourceType: String
    let loginStatus: String
    let platform: String
    let isWifi: Bool
    let service: String
    let developmentVersion: String
    let paymentMethod: String? //Should be sent after package purchase. Value is Turkcell or inApp
    let userId: String
    let operatorSystem: String
    let facialRecognition: Bool
    let userPackagesNames: [String] //Pacakage names that the user owns should be sent with every page click. Pacakage names should be seperated with pipe "|"
    let countOfUploadMetric: Int?
    let countOfDownloadMetric: Int?
    
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
            GADementionsFields.pageType.text : pageType.name,
            GADementionsFields.sourceType.text : sourceType,
            GADementionsFields.loginStatus.text : loginStatus,
            GADementionsFields.platform.text : platform,
            GADementionsFields.networkFixWifi.text : "\(isWifi)",
            GADementionsFields.service.text : service,
            GADementionsFields.developmentVersion.text : developmentVersion,
            GADementionsFields.userID.text : userId,
            GADementionsFields.operatorSystem.text : operatorSystem,
            GADementionsFields.faceImageStatus.text : "\(facialRecognition)",
            GADementionsFields.userPackage.text : userOwnedPackages
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
        return dimesionDictionary
    }
}

//struct AnalyticsDementsonWithMetricsObject {
//
//}
