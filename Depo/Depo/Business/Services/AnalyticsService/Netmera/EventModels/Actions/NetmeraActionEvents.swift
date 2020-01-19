//
//  NetmeraActionEvents.swift
//  Depo
//
//  Created by Alex on 1/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

extension NetmeraEvents.Actions {

    final class Login: NetmeraEvent {
        
        private let kLoginKey = "rvw"
        
        @objc var status = ""
        @objc var loginType = ""
        
        convenience init(status: NetmeraEventValues.GeneralStatus, loginType: NetmeraEventValues.LoginType) {
            self.init()
            self.status = status.text
            self.loginType = loginType.text
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ea" : #keyPath(status),//NSStringFromSelector(#selector(getter: self.status)),
                "eb" : #keyPath(loginType),//NSStringFromSelector(#selector(getter: self.loginType)),
            ]
        }
        
        override var eventKey : String {
            return kLoginKey
        }
    }
    
    final class SignUp: NetmeraEvent {
        
        private let kSignupKey = "ylx"
        
        @objc var status = ""
        
        convenience init(status: NetmeraEventValues.GeneralStatus) {
            self.init()
            self.status = status.text
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ea" : #keyPath(status),
            ]
        }
        
        override var eventKey : String {
            return kSignupKey
        }
    }
    
    final class Import: NetmeraEvent {
        
        private let kImportKey = "qfv"
        
        @objc var channelType = ""
        @objc var status = ""
        
        convenience init(status: NetmeraEventValues.OnOffSettings, socialType: Section.SocialAccount) {
            let socialChannel: NetmeraEventValues.ImportChannelType
            switch socialType {
            case .dropbox:
                socialChannel = .dropbox
            case .facebook:
                socialChannel = .facebook
            case .instagram:
                socialChannel = .instagram
            case .spotify:
                socialChannel = .spotify
            }
            self.init(status: status.text, channelType: socialChannel.text)
        }
        
        convenience init(status: String, channelType: String) {
            self.init()
            self.status = status
            self.channelType = channelType
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return[
                "eb" : #keyPath(status),
                "ea" : #keyPath(channelType),
            ]
        }
        
        override var eventKey : String {
            return kImportKey
        }
    }
    
    final class EmailVerification: NetmeraEvent {
        
        private let kEmailVerificationKey = "axi"
        
        @objc var action = ""
        
        convenience init(action: NetmeraEventValues.GeneralStatus) {
            self.init()
            self.action = action.text
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return[
                "ea" : #keyPath(action),
            ]
        }
        
        override var eventKey : String {
            return kEmailVerificationKey
        }
    }
    
    final class PackageChannelClick: NetmeraEvent {
        
        private let kPackageChannelClickKey = "tvm"
        
        @objc var type = ""
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ea": #keyPath(type)
            ]
        }
        
        override var eventKey : String {
            return kPackageChannelClickKey
        }
    }
    
    final class Edit: NetmeraEvent {
        
        private let kEditKey = "nsg"
        
        @objc var status = ""
        
        convenience init(status: NetmeraEventValues.GeneralStatus) {
            self.init()
            self.status = status.text
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return[
                "ea" : #keyPath(status),
            ]
        }
        
        override var eventKey : String {
            return kEditKey
        }
    }
    
    final class Share: NetmeraEvent {
        
        private let kShareKey = "bkv"
        
        @objc var method = ""
        @objc var channelType = ""
        
        convenience init(method: String, channelType: String) {
            self.init()
            self.method = method
            self.channelType = channelType
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ea" : #keyPath(method),
                "eb" : #keyPath(channelType),
            ]
        }
        
        override var eventKey : String {
            return kShareKey
        }
    }
    
    final class CreateStory: NetmeraEvent {
        
        private let kCreateStoryKey = "wed"
        
        @objc var status = ""
        
        convenience init(status: NetmeraEventValues.GeneralStatus) {
            self.init()
            self.status = status.text
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ea" : #keyPath(status),
            ]
        }
        
        override var eventKey : String {
            return kCreateStoryKey
        }
    }
    
    final class FirstAutosync: NetmeraEvent {
        
        private let kFirstAutosyncKey = "ekh"
        
        @objc var syncSetting = ""
        @objc var photos = ""
        @objc var videos = ""
        
        convenience init(autosyncSettings: AutoSyncSettings) {
            
            let state = autosyncSettings.isAutoSyncOptionEnabled ? NetmeraEventValues.OnOffSettings.on : NetmeraEventValues.OnOffSettings.off
            
            let photoOption: NetmeraEventValues.AutoSyncState
            let videoOption: NetmeraEventValues.AutoSyncState
            
            switch autosyncSettings.photoSetting.option {
            case .never:
                photoOption = NetmeraEventValues.AutoSyncState.never
            case .wifiAndCellular:
                photoOption = NetmeraEventValues.AutoSyncState.wifi_LTE
            case .wifiOnly:
                photoOption = NetmeraEventValues.AutoSyncState.wifi
            }
            
            switch autosyncSettings.videoSetting.option {
            case .never:
                videoOption = NetmeraEventValues.AutoSyncState.never
            case .wifiAndCellular:
                videoOption = NetmeraEventValues.AutoSyncState.wifi_LTE
            case .wifiOnly:
                videoOption = NetmeraEventValues.AutoSyncState.wifi
            }
            
            self.init(videos: videoOption, autosyncSetting: state, photos: photoOption)
            
        }
        
        convenience init(videos: NetmeraEventValues.AutoSyncState, autosyncSetting: NetmeraEventValues.OnOffSettings, photos:  NetmeraEventValues.AutoSyncState) {
            self.init()
            self.syncSetting = autosyncSetting.text
            self.photos = photos.text
            self.videos = videos.text
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ee" : #keyPath(syncSetting),
                "ea" : #keyPath(photos),
                "eb" : #keyPath(videos),
            ]
        }
        
        override var eventKey : String {
            return kFirstAutosyncKey
        }
    }
    
    final class Download: NetmeraEvent {
        
        private let kDownloadKey = "wgb"
        
        @objc var type = ""
        @objc var count: Int = 0
        
        convenience init(type: FileType, count: Int) {
            let accaptableType: NetmeraEventValues.DownloadType
            switch type {
            case .image, .faceImage(_):
                accaptableType = .photo
            case .video:
                accaptableType = .video
            case .application(.doc), .application(.txt),
                 .application(.html), .application(.xls),
                 .application(.pdf), .application(.ppt),
                 .application(.usdz), .allDocs:
                accaptableType = .document
            case .audio:
                accaptableType = .music
            case .photoAlbum, .faceImageAlbum(_):
                accaptableType = .album
            default:
                accaptableType = .photo
            }
            self.init(type: accaptableType, count: count)
            
        }
        
        convenience init(type: NetmeraEventValues.DownloadType, count: Int) {
            self.init()
            self.type = type.text
            self.count = count
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ea" : #keyPath(type),
                "ec" : #keyPath(count),
            ]
        }
        
        override var eventKey : String {
            return kDownloadKey
        }
    }
    
    final class FreeUpSpace: NetmeraEvent {
        
        private let kFreeupspaceKey: String = "kxj"
        
        @objc var count: Int = 0
        
        convenience init(count: Int) {
            self.init()
            self.count = count
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return ["ec" : #keyPath(count)]
        }
        
        override var eventKey : String {
            return kFreeupspaceKey
        }
    }
    
    final class PackageClick: NetmeraEvent {
        
        private let kPackageClickKey = "hzp"
        
        @objc var packageName = ""
        
        convenience init(packageName: String) {
            self.init()
            self.packageName = packageName
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ee" : #keyPath(packageName),
            ]
        }
        
        override var eventKey : String {
            return kPackageClickKey
        }
    }
    
    final class Delete: NetmeraEvent {
        
        private let kDeleteKey = "trb"
        
        @objc var status = ""
        
        convenience init(status: String) {
            self.init()
            self.status = status
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ea" : #keyPath(status),
            ]
        }
        
        override var eventKey : String {
            return kDeleteKey
        }
    }
    
    final class AppPermission: NetmeraEvent {
        
        private let kAppPermissionKey = "eug"
        
        @objc var value = ""
        @objc var type = ""
        @objc var status = ""
        
        convenience init(value: String, type: String, status: String) {
            self.init()
            self.value = value
            self.type = type
            self.status = status
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return[
                "ee" : #keyPath(value),
                "ea" : #keyPath(type),
                "eb" : #keyPath(status),
            ]
        }
        
        override var eventKey : String {
            return kAppPermissionKey
        }
    }
    
    final class StandardUserFIRGroupingON: NetmeraEvent {
        
        private let kStandardUserFIGroupingONKey = "hjz"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kStandardUserFIGroupingONKey
        }
    }
    
    final class StandardUserFIGroupingOFF: NetmeraEvent {
        
        private let kStandardUserFIGroupingOFFKey = "qml"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kStandardUserFIGroupingOFFKey
        }
    }
    
    final class TwoFactorAuthentication: NetmeraEvent {
        
        private let kTwoFactorAuthenticationKey = "cqh"
        
        @objc var action = ""
        
        convenience init(action: NetmeraEventValues.OnOffSettings) {
            self.init()
            self.action = action.text
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ea" : #keyPath(action),
            ]
        }
        
        override var eventKey : String {
            return kTwoFactorAuthenticationKey
        }
    }
    
    final class Upload: NetmeraEvent {
        
        private let kUploadKey = "znx"
        
        @objc var uploadType = ""
        @objc var fileType = ""
        
        convenience init(uploadType: UploadType, fileTypes: [FileType]) {
            
            var acceptableType = ""
            fileTypes.forEach {
                let appopriateFileType: NetmeraEventValues.UploadFileType
                switch $0 {
                case .image, .faceImage(_):
                    appopriateFileType = .photo
                case .video:
                    appopriateFileType = .video
                case .audio:
                    appopriateFileType = .music
                case .application(.doc), .application(.txt),
                     .application(.html), .application(.xls),
                     .application(.pdf), .application(.ppt),
                     .application(.usdz), .allDocs:
                    appopriateFileType = .document
                default:
                    appopriateFileType = .photo
                }
                acceptableType += "/\(appopriateFileType.text)"
            }
            
            
            let appopriateUploadType: NetmeraEventValues.UploadType
            
            switch uploadType {
            case .autoSync:
                if UIApplication.shared.applicationState == .background {
                    appopriateUploadType = .background
                } else {
                    appopriateUploadType = .autosync
                }
            case .fromHomePage, .syncToUse, .other:
                appopriateUploadType = .manual
                
            }
            
            self.init(uploadType: appopriateUploadType, fileTypeStr: acceptableType)
        }
        
        convenience init(uploadType: NetmeraEventValues.UploadType, fileTypeStr: String) {
            self.init()
            self.uploadType = uploadType.text
            self.fileType = fileTypeStr
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ea" : #keyPath(uploadType),
                "eb" : #keyPath(fileType),
            ]
        }
        
        override var eventKey : String {
            return kUploadKey
        }
    }
    
    final class PackagePurchase: NetmeraEvent {
        
        private let kPackagePurchaseKey = "zfz"
        
        @objc var status = ""
        
        convenience init(status: String) {
            self.init()
            self.status = status
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "eb" : #keyPath(status),
            ]
        }
        
        override var eventKey : String {
            return kPackagePurchaseKey
        }
    }
    
    final class Autosync: NetmeraEvent {
        
        private let kAutosyncKey = "tkp"
        
        @objc var videos = ""
        @objc var autosyncSetting = ""
        @objc var photos = ""
        
        convenience init(autosyncSettings: AutoSyncSettings) {
            
            let state = autosyncSettings.isAutoSyncOptionEnabled ? NetmeraEventValues.OnOffSettings.on : NetmeraEventValues.OnOffSettings.off
            
            let photoOption: NetmeraEventValues.AutoSyncState
            let videoOption: NetmeraEventValues.AutoSyncState
            
            switch autosyncSettings.photoSetting.option {
            case .never:
                photoOption = NetmeraEventValues.AutoSyncState.never
            case .wifiAndCellular:
                photoOption = NetmeraEventValues.AutoSyncState.wifi_LTE
            case .wifiOnly:
                photoOption = NetmeraEventValues.AutoSyncState.wifi
            }
            
            switch autosyncSettings.videoSetting.option {
            case .never:
                videoOption = NetmeraEventValues.AutoSyncState.never
            case .wifiAndCellular:
                videoOption = NetmeraEventValues.AutoSyncState.wifi_LTE
            case .wifiOnly:
                videoOption = NetmeraEventValues.AutoSyncState.wifi
            }
            
            self.init(videos: videoOption, autosyncSetting: state, photos: photoOption)
            
        }
        
        convenience init(videos: NetmeraEventValues.AutoSyncState, autosyncSetting: NetmeraEventValues.OnOffSettings, photos:  NetmeraEventValues.AutoSyncState) {
            self.init()
            self.videos = videos.text
            self.autosyncSetting = autosyncSetting.text
            self.photos = photos.text
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ee" : #keyPath(videos),
                "ea" : #keyPath(autosyncSetting),
                "eb" : #keyPath(photos),
            ]
        }
        
        override var eventKey : String {
            return kAutosyncKey
        }
    }
    
    final class FaceImageGrouping: NetmeraEvent {
        
        private let kFaceImageGroupingKey = "jxo"
        
        @objc var action = ""
        
        convenience init(action: NetmeraEventValues.OnOffSettings) {
            self.init()
            self.action = action.text
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ea" : #keyPath(action),
            ]
        }
        
        override var eventKey : String {
            return kFaceImageGroupingKey
        }
    }
    
    final class ButonClick: NetmeraEvent {
        
        private let kButonClickKey = "jpj"
        
        @objc var buttonName = ""
        
        convenience init(buttonName: String) {
            self.init()
            self.buttonName = buttonName
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ea" : #keyPath(buttonName),
            ]
        }
        
        override var eventKey : String {
            return kButonClickKey
        }
    }
    
    final class AddToAlbum: NetmeraEvent {
        
        private let kAddToAlbumKey = "ddj"
        
        @objc var status = ""
        
        convenience init(status: NetmeraEventValues.GeneralStatus) {
            self.init()
            self.status = status.text
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ea" : #keyPath(status),
            ]
        }
        
        override var eventKey : String {
            return kAddToAlbumKey
        }
    }
    
    final class Contact: NetmeraEvent {
        
        private let kContactKey = "tda"
        
        @objc var action = ""
        @objc var status = ""
        
        convenience init(actionType: NetmeraEventValues.ContactBackupType, staus: NetmeraEventValues.GeneralStatus) {
            self.init(action: actionType.text, status: staus.text)
        }
        
        convenience init(action: String, status: String) {
            self.init()
            self.action = action
            self.status = status
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ea" : #keyPath(action),
                "eb" : #keyPath(status),
            ]
        }
        
        override var eventKey : String {
            return kContactKey
        }
    }
    
    final class Trash: NetmeraEvent {
        
        private let kTrashKey = "wtp"
        
        @objc var status = ""
        @objc var type = ""
        @objc var count: Int = 0
        
        convenience init?(status: NetmeraEventValues.GeneralStatus, typeCountTupple: NetmeraService.ItemTypeToCountTupple) {
            guard typeCountTupple.1 > 0 else {
                assertionFailure("please add additional check before calling init, otherwise we will send a lot of nills")
                return nil
            }
            
            let accaptableType: NetmeraEventValues.TrashType
            switch typeCountTupple.0 {
            case .image, .faceImage(_):
                accaptableType = .photo
            case .video:
                accaptableType = .video
            case .application(.doc), .application(.txt),
                 .application(.html), .application(.xls),
                 .application(.pdf), .application(.ppt),
                 .application(.usdz), .allDocs:
                accaptableType = .document
            case .audio:
                accaptableType = .music
            case .photoAlbum:
                accaptableType = .album
            case .faceImageAlbum(.people):
                accaptableType = .person
            case .faceImageAlbum(.things):
                accaptableType = .thing
            case .faceImageAlbum(.places):
                accaptableType = .place
            default:
                accaptableType = .photo
            }
            
            self.init(status: status.text, type: accaptableType.text, count: typeCountTupple.1)
        }
        
        convenience init(status: String, type: String, count: Int) {
            self.init()
            self.status = status
            self.type = type
            self.count = count
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ea" : #keyPath(status),
                "eb" : #keyPath(type),
                "ec" : #keyPath(count),
            ]
        }
        
        override var eventKey : String {
            return kTrashKey
        }
    }
    
    final class NonStandardUserFIGroupingOFF: NetmeraEvent {
         
         private let kNonStandardUserFIGroupingOFFKey = "you"
         
         override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
             return [:]
         }
         
         override var eventKey : String {
             return kNonStandardUserFIGroupingOFFKey
         }
     }
    
    final class Photopick: NetmeraEvent {
        
        private let kPhotopickKey = "tnm"
        
        @objc var leftAnalysis = ""
        @objc var status = ""
        
        convenience init(leftAnalysis: NetmeraEventValues.PhotopickUserAnalysisLeft, status: NetmeraEventValues.GeneralStatus) {
            self.init()
            self.leftAnalysis = leftAnalysis.text
            self.status = status.text
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ea" : #keyPath(leftAnalysis),
                "eb" : #keyPath(status),
            ]
        }
        
        override var eventKey : String {
            return kPhotopickKey
        }
    }
    
}
