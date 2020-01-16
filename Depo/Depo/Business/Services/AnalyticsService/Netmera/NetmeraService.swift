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
        let user = NetmeraCustomUser()
        user.userId = SingletonStorage.shared.accountInfo?.gapId ?? ""

//        user.dictionaryValueWithClassInfo()
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

