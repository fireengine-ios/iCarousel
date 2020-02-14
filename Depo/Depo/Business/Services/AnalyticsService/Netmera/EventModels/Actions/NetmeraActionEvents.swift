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
        
        convenience init(channelType: PaymentType) {
            self.init()
            switch channelType {
            case .appStore:
                self.type = NetmeraEventValues.PackageChannelType.inAppStorePurchase.text
            case .paycell:
                self.type = NetmeraEventValues.PackageChannelType.creditCard.text
            case .slcm:
                self.type = NetmeraEventValues.PackageChannelType.chargeToBill.text
            }
            
        }
        
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
        
        convenience init(method: NetmeraEventValues.ShareMethodType, channelType: String) {
            
            self.init(method: method.text, channelType: channelType)
        }
        
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
        @objc var type = ""
        @objc var count: Int = 0

        convenience init?(status: NetmeraEventValues.GeneralStatus, type: FileType, count: Int) {
            guard count > 0 else {
                assertionFailure("please add additional check before calling init, otherwise we will send a lot of nills")
                return nil
            }
            
            let acceptableType: NetmeraEventValues.TrashType
            switch type {
            case .image:
                acceptableType = .photo
            case .video:
                acceptableType = .video
            case .application(.doc), .application(.txt),
                 .application(.html), .application(.xls),
                 .application(.pdf), .application(.ppt),
                 .application(.usdz), .allDocs:
                acceptableType = .document
            case .audio:
                acceptableType = .music
            case .photoAlbum:
                acceptableType = .album
            case .faceImageAlbum(.people), .faceImage(.people):
                acceptableType = .person
            case .faceImageAlbum(.things), .faceImage(.things):
                acceptableType = .thing
            case .faceImageAlbum(.places), .faceImage(.places):
                acceptableType = .place
            default:
                acceptableType = .photo
            }
            
            self.init(status: status.text, type: acceptableType.text, count: count)
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
            ]
        }
        
        override var eventKey : String {
            return kDeleteKey
        }
    }
    
    final class Restore: NetmeraEvent {
        
        private let kRestoreKey = "hjo"
        
        @objc var status = ""
        @objc var type = ""
        @objc var count: Int = 0

        convenience init?(status: NetmeraEventValues.GeneralStatus, type: FileType, count: Int) {
            guard count > 0 else {
                assertionFailure("please add additional check before calling init, otherwise we will send a lot of nills")
                return nil
            }
            
            let acceptableType: NetmeraEventValues.RestoredType
            switch type {
            case .image:
                acceptableType = .photo
            case .video:
                acceptableType = .video
            case .application(.doc), .application(.txt),
                 .application(.html), .application(.xls),
                 .application(.pdf), .application(.ppt),
                 .application(.usdz), .allDocs:
                acceptableType = .document
            case .audio:
                acceptableType = .music
            case .photoAlbum:
                acceptableType = .album
            case .faceImageAlbum(.people), .faceImage(.people):
                acceptableType = .person
            case .faceImageAlbum(.things), .faceImage(.things):
                acceptableType = .thing
            case .faceImageAlbum(.places), .faceImage(.places):
                acceptableType = .place
            default:
                acceptableType = .photo
            }
            
            self.init(status: status.text, type: acceptableType.text, count: count)
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
            return kRestoreKey
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
        
        convenience init(uploadType: UploadType, fileTypes: FileType) {
            
            let appopriateFileType: NetmeraEventValues.UploadFileType
            switch fileTypes {
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
            
            let appopriateUploadType: NetmeraEventValues.UploadType
            
            switch uploadType {
            case .autoSync:
                if UIApplication.shared.applicationState == .background {
                    appopriateUploadType = .background
                } else {
                    appopriateUploadType = .autosync
                }
            case .upload, .syncToUse:
                appopriateUploadType = .manual
            }
            
            self.init(uploadType: appopriateUploadType, fileTypeStr: appopriateFileType.text)
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
        
        convenience init(status: NetmeraEventValues.GeneralStatus) {
            self.init(status: status.text)
        }
        
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
    
    final class ButtonClick: NetmeraEvent {
        
        private let kButtonClickKey = "jpj"
        
        @objc var buttonName = ""
        
        convenience init(buttonName: NetmeraEventValues.ButtonName) {
            self.init(buttonName: buttonName.text)
        }
        
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
            return kButtonClickKey
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
        
        convenience init?(status: NetmeraEventValues.GeneralStatus, type: FileType, count: Int) {
            guard count > 0 else {
                assertionFailure("please add additional check before calling init, otherwise we will send a lot of nills")
                return nil
            }
            
            let acceptableType: NetmeraEventValues.TrashType
            switch type {
            case .image:
                acceptableType = .photo
            case .video:
                acceptableType = .video
            case .application(.doc), .application(.txt),
                 .application(.html), .application(.xls),
                 .application(.pdf), .application(.ppt),
                 .application(.usdz), .allDocs:
                acceptableType = .document
            case .audio:
                acceptableType = .music
            case .photoAlbum:
                acceptableType = .album
            case .faceImageAlbum(.people), .faceImage(.people):
                acceptableType = .person
            case .faceImageAlbum(.things), .faceImage(.things):
                acceptableType = .thing
            case .faceImageAlbum(.places), .faceImage(.places):
                acceptableType = .place
            default:
                acceptableType = .photo
            }
            
            self.init(status: status.text, type: acceptableType.text, count: count)
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
    
    

    class SmashSave: NetmeraEvent {
        
        private let kSmashKey = "tal"
        
        @objc var stickerId = [String]()
        @objc var action = ""
        @objc var gifId = [String]()

        convenience init(action: NetmeraEventValues.SmashAction, stickerId: [String], gifId: [String]) {
            self.init()
            self.stickerId = stickerId
            self.gifId = gifId
            self.action = action.text
        }

        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return[
                "ee" : #keyPath(stickerId),
                "ea" : #keyPath(action),
                "eb" : #keyPath(gifId),
            ]
        }
        override var eventKey : String {
            return kSmashKey
        }
    }
    
    

    class Unhide: NetmeraEvent {
        
        private let kUnhideKey = "eew"
        
        @objc var status = ""
        @objc var type = ""
        @objc var count: Int = 0

        convenience init(status: NetmeraEventValues.GeneralStatus, type: NetmeraEventValues.HideUnhideObjectType, count: Int) {
            self.init()
            self.status = status.text
            self.type = type.text
            self.count = count
        }
        
        convenience init?(status: NetmeraEventValues.GeneralStatus, type: FileType, count: Int) {
        guard count > 0 else {
                assertionFailure("please add additional check before calling init, otherwise we will send a lot of nills")
                return nil
            }
            let acceptableType: NetmeraEventValues.HideUnhideObjectType
            switch type {
            case .image:
                acceptableType = .photo
            case .video:
                acceptableType = .video
            case .photoAlbum:
                acceptableType = .album
            case .faceImageAlbum(.people), .faceImage(.people):
                acceptableType = .person
            case .faceImageAlbum(.things), .faceImage(.things):
                acceptableType = .thing
            case .faceImageAlbum(.places), .faceImage(.places):
                acceptableType = .place
            default:
                acceptableType = .photo
            }
            
            self.init(status: status, type: acceptableType, count: count)
        }

        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return[
                "ea" : #keyPath(status),
                "eb" : #keyPath(type),
                "ec" : #keyPath(count),
            ]
        }
        override var eventKey : String {
            return kUnhideKey
        }
    }

    class Hide: NetmeraEvent {
        
        let kHideKey = "tfe"
        
        @objc var status = ""
        @objc var type = ""
        @objc var count: Int = 0

        convenience init?(status: NetmeraEventValues.GeneralStatus, type: FileType, count: Int) {
            guard count > 0 else {
                assertionFailure("please add additional check before calling init, otherwise we will send a lot of nills")
                return nil
            }
            let acceptableType: NetmeraEventValues.HideUnhideObjectType
            switch type {
            case .image:
                acceptableType = .photo
            case .video:
                acceptableType = .video
            case .photoAlbum:
                acceptableType = .album
            case .faceImageAlbum(.people), .faceImage(.people):
                acceptableType = .person
            case .faceImageAlbum(.things), .faceImage(.things):
                acceptableType = .thing
            case .faceImageAlbum(.places), .faceImage(.places):
                acceptableType = .place
            default:
                acceptableType = .photo
            }
            
            self.init(status: status, type: acceptableType, count: count)
        }
        
        convenience init(status: NetmeraEventValues.GeneralStatus, type: NetmeraEventValues.HideUnhideObjectType, count: Int) {
            self.init()
            self.status = status.text
            self.type = type.text
            self.count = count
        }

        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return[
                "ea" : #keyPath(status),
                "eb" : #keyPath(type),
                "ec" : #keyPath(count),
            ]
        }
        override var eventKey : String {
            return kHideKey
        }
    }
    
}
