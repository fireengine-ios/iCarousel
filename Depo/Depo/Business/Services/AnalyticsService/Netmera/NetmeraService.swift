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
        //TODO: add cases for each events and inside reponsable extension add method that returns it.
    }
    enum Screens {
    }
}

final class NetmeraService {
 
    static func updateUser() {
        
        let tokenStorage: TokenStorage = factory.resolve()
        let loginStatus = tokenStorage.accessToken != nil
        
        
        let deviceUsedStorage = Int((1 - Device.getFreeDiskSpaceInPercent)*100)
        
        if loginStatus {
            
            let group = DispatchGroup()
            
            let autoSyncStorageSettings = AutoSyncDataStorage().settings
            let instapickService: InstapickService = factory.resolve()
            let accountService = AccountService()
            
            group.enter()
            var nemeraAnalysisLeft = ""
            instapickService.getAnalyzesCount { analyzeResult in
                switch analyzeResult {
                case .success(let analysisCount):
                    nemeraAnalysisLeft = analysisCount.isFree ? NetmeraEventValues.PhotopickUserAnalysisLeft.premium.text : NetmeraEventValues.PhotopickUserAnalysisLeft.regular(analysisLeft: analysisCount.left).text
                case .failed(_):
                    nemeraAnalysisLeft = "Null"
                }
                group.leave()
            }

            var lifeboxStorage: Int = 0
            group.enter()
            accountService.usage(
                success: { response in
                    guard let usage = response as? UsageResponse else {
                        return
                    }
                    lifeboxStorage = Int(usage.totalUsage ?? 0)
                    
                    group.leave()
                }, fail: { errorResponse in

                    group.leave()
            })
            

            var firGrouping = ""
            group.enter()
            SingletonStorage.shared.getFaceImageSettingsStatus(success: { isEnabled in
                firGrouping = isEnabled ? NetmeraEventValues.OnOffSettings.on.text : NetmeraEventValues.OnOffSettings.off.text
                group.leave()
            }, fail: { _ in
                firGrouping = "Null"
                group.leave()
            })
            
            var accountType = "Null"
            switch AuthoritySingleton.shared.accountType {
            case .standart:
                accountType = NetmeraEventValues.AccountType.standart.text
            case .middle:
                accountType = NetmeraEventValues.AccountType.standartPlus.text
            case .premium:
                accountType = NetmeraEventValues.AccountType.premium.text
            }
            
            let isTwoFactorAuthEnabled = SingletonStorage.shared.isTwoFactorAuthEnabled ?? false
            let twoFactorNetmeraStatus = isTwoFactorAuthEnabled ? NetmeraEventValues.OnOffSettings.on.text : NetmeraEventValues.OnOffSettings.off.text
            
            
            let confirmedAutoSyncSettingsState = autoSyncStorageSettings.isAutoSyncEnabled && autoSyncStorageSettings.isAutosyncSettingsApplied
            let autoSyncState = confirmedAutoSyncSettingsState ? NetmeraEventValues.OnOffSettings.on.text : NetmeraEventValues.OnOffSettings.off.text
            
            let netmeraAutoSyncStatusPhoto: String
            let netmeraAutoSyncStatusVideo: String
            if confirmedAutoSyncSettingsState {
                netmeraAutoSyncStatusPhoto = NetmeraEventValues.AutoSyncState.getState(autosyncSettings: autoSyncStorageSettings.photoSetting).text
                netmeraAutoSyncStatusVideo = NetmeraEventValues.AutoSyncState.getState(autosyncSettings: autoSyncStorageSettings.videoSetting).text
            } else {
                netmeraAutoSyncStatusPhoto = NetmeraEventValues.AutoSyncState.never.text
                netmeraAutoSyncStatusVideo = NetmeraEventValues.AutoSyncState.never.text
            }
                
            
            group.enter()
            var activeSubscriptionNames = [String]()
            SingletonStorage.shared.getActiveSubscriptionsList(success: { response in
                activeSubscriptionNames = SingletonStorage.shared.activeUserSubscriptionList.map {
                    return ($0.subscriptionPlanName ?? "") + "|"
                }
                group.leave()
            }, fail: { errorResponse in
                group.leave()
            })
            
            //TODO: Check if this is correct
            let verifiedEmail = SingletonStorage.shared.isEmailVerificationCodeSent ? NetmeraEventValues.EmailVerification.verified.text : NetmeraEventValues.EmailVerification.notVerified.text
            

            
            group.notify(queue: DispatchQueue.global()) {
                let user = NetmeraCustomUser(deviceStorage: deviceUsedStorage,
                                             photopickLeftAnalysis: nemeraAnalysisLeft,
                                             lifeboxStorage: lifeboxStorage,
                                             faceImageGrouping: firGrouping,
                                             accountType: accountType,
                                             twoFactorAuthentication: twoFactorNetmeraStatus,
                                             autosync: autoSyncState,
                                             emailVerification: verifiedEmail,
                                             autosyncPhotos: netmeraAutoSyncStatusPhoto,
                                             autosyncVideos: netmeraAutoSyncStatusVideo,
                                             packages: activeSubscriptionNames,
                                             autoLogin: "Null",
                                             turkcellPassword: "Null")
                
                user.userId = SingletonStorage.shared.accountInfo?.gapId ?? ""
                Netmera.update(user)
            }
            

        } else {
            let user = NetmeraCustomUser(deviceStorage: deviceUsedStorage, photopickLeftAnalysis: "Null", lifeboxStorage: 0, faceImageGrouping: "Null", accountType: "Null",
                twoFactorAuthentication: "Null", autosync: "Null", emailVerification: "Null",
                autosyncPhotos: "Null", autosyncVideos: "Null", packages: ["Null"],
                autoLogin: "Null", turkcellPassword: "Null")
            user.userId = SingletonStorage.shared.accountInfo?.gapId ?? ""
            Netmera.update(user)
        }

        
        
//        }}{{  user.autosync = @"On";
//        autosyncPhotos: Never/Wifi/Wifi_LTE
//        autosyncVideos: Never/Wifi/Wifi_LTE
        
        //        lifeboxStorage:{used_percentage_value} : Settings/Account Detail/ My Storage
        
        //        twoFactorAuthentication: On/Off
        
        //        emailVerification: Verified/NotVerified
        
        
        
//        deviceStorage:{used_percentage_value} : It shows how many storage used on the device.
//        faceImageGrouping: On/Off
//        photopickLeftAnalysis:{count_of_left_analysis} : If user is premium, the value should be 'Free'.
//        accountType: Standard/Standard+/Premium : Settings/Account Detail/ Account Type

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
        
        //FIXME: REMOVE  "|| RELEASE" part
        #if APPSTORE
        Netmera.setAPIKey("3PJRHrXDiqbDyulzKSM_m59cpbYT9LezJOwQ9zsHAkjMSBUVQ92OWw")
        #elseif  RELEASE
        Netmera.setAPIKey("3PJRHrXDiqa-pwWScAq1PwON_uN9F4h_7_vf0s3AwgwwqNTCnPZ_Bg")
        #elseif ENTERPRISE || DEBUG
        Netmera.setAPIKey("3PJRHrXDiqa-pwWScAq1P9AgrOteDDLvwaHjgjAt-Ohb1OnTxfy_8Q")
        #endif
        
        Netmera.setAppGroupName(SharedConstants.groupIdentifier)
    }
    
    static func sendEvent(event: NetmeraEvent) {
        Netmera.send(event)
    }
    
    typealias ItemTypeToCountTupple = (FileType, Int)
    static func getItemsTypeToCount(items: [BaseDataSourceItem]) -> ([ItemTypeToCountTupple]) {
        var photos =  [Item]()
        var videos =  [Item]()
        var documents =  [Item]()
        var music =  [Item]()
        var firAlbumsPlaces = [Item]()
        var firAlbumsPeople = [Item]()
        var firAlbumsThings = [Item]()
        var albums =  [BaseDataSourceItem]()
        
        for item in items {
            if let wrapDataItem = item as? Item {
                switch wrapDataItem.fileType {
                case .image, .faceImage(_):
                    photos.append(wrapDataItem)
                case .video:
                    videos.append(wrapDataItem)
                case .application(.doc), .application(.txt),
                     .application(.html), .application(.xls),
                     .application(.pdf), .application(.ppt),
                     .application(.usdz), .allDocs:
                    documents.append(wrapDataItem)
                case .audio:
                    music.append(wrapDataItem)
                case .photoAlbum:
                    albums.append(wrapDataItem)
                case .faceImageAlbum(.people):
                    firAlbumsPeople.append(wrapDataItem)
                case .faceImageAlbum(.things):
                    firAlbumsThings.append(wrapDataItem)
                case .faceImageAlbum(.places):
                    firAlbumsPlaces.append(wrapDataItem)
                default:
                    break
                }
                
            } else if let regularAlbum = item as? AlbumItem {
                albums.append(regularAlbum)
            }
        }
        return [
            (.image, photos.count),
            (.video, videos.count),
            (.allDocs, documents.count),
            (.audio, music.count),
            (.photoAlbum, albums.count),
            (.faceImageAlbum(.people), firAlbumsPeople.count),
            (.faceImageAlbum(.things), firAlbumsThings.count),
            (.faceImageAlbum(.places), firAlbumsPlaces.count)
        ]
    }
}

