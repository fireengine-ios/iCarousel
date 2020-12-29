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
        @objc var errorType = ""
        
        convenience init(status: NetmeraEventValues.GeneralStatus, errorType: String? = nil) {
            self.init()
            self.status = status.text
            self.errorType = errorType ?? ""
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ea" : #keyPath(status),
                "eb" : #keyPath(errorType),
            ]
        }
        
        override var eventKey : String {
            return kSignupKey
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
        @objc var packageName = ""
        
        convenience init(channelType: PaymentType, packageName: String) {
            self.init()
            self.packageName = packageName
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
                "ea": #keyPath(type),
                "eb" : #keyPath(packageName)
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
        @objc var duration = ""
        
        convenience init(method: NetmeraEventValues.ShareMethodType, channelType: String, duration: PrivateShareDuration? = nil) {
            
            self.init(method: method.text, channelType: channelType, duration: duration)
        }
        
        convenience init(method: String, channelType: String, duration: PrivateShareDuration? = nil) {
            self.init()
            self.method = method
            self.channelType = channelType
            self.duration = duration?.rawValue ?? ""
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ea" : #keyPath(method),
                "eb" : #keyPath(channelType),
                "ee" : #keyPath(duration)
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
    
    final class Download: NetmeraEvent {
        
        private let kDownloadKey = "wgb"
        
        @objc var type = ""
        @objc var count: Int = 0
        
        convenience init(type: FileType, count: Int) {
            let accaptableType: NetmeraEventValues.DownloadType
            switch type {
            case .image:
                accaptableType = .photo
            case .video:
                accaptableType = .video
            case .application(.doc), .application(.txt),
                 .application(.html), .application(.xls),
                 .application(.pdf), .application(.ppt),
                 .application(.usdz), .application(.pptx) ,.allDocs:
                accaptableType = .document
            case .audio:
                accaptableType = .music
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
    
    final class PackageCancelClick: NetmeraEvent {
        
        private let kPackageCancelClickKey = "iwj"
        
        @objc var packageName = ""
        @objc var type = ""
        
        convenience init(type: String, packageName: String) {
            self.init()
            self.packageName = packageName
            self.type = type
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "eb" : #keyPath(type),
                "ea" : #keyPath(packageName)
            ]
        }
        
        override var eventKey : String {
            return kPackageCancelClickKey
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
                 .application(.pdf), .application(.ppt), .application(.pptx),
                 .application(.usdz), .allDocs:
                acceptableType = .document
            case .audio:
                acceptableType = .music
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
                 .application(.pdf), .application(.ppt), .application(.pptx),
                 .application(.usdz), .allDocs:
                acceptableType = .document
            case .audio:
                acceptableType = .music
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
            case .image:
                appopriateFileType = .photo
            case .video:
                appopriateFileType = .video
            case .audio:
                appopriateFileType = .music
            case .application(.doc), .application(.txt),
                 .application(.html), .application(.xls),
                 .application(.pdf), .application(.ppt), .application(.pptx),
                 .application(.usdz), .allDocs:
                appopriateFileType = .document
            default:
                appopriateFileType = .photo
            }
            
            let appopriateUploadType: NetmeraEventValues.UploadType
            
            switch uploadType {
            case .autoSync:
                if ApplicationStateHelper.shared.isBackground {
                    appopriateUploadType = .background
                } else {
                    appopriateUploadType = .autosync
                }
                case .upload, .syncToUse, .save, .saveAs, .sharedWithMe:
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
        @objc var type = ""
        @objc var packageName = ""
        
        convenience init(status: NetmeraEventValues.GeneralStatus, channelType: PaymentType, packageName: String) {
            self.init(status: status.text, channelType: channelType, packageName: packageName)
        }
        
        convenience init(status: String, channelType: PaymentType, packageName: String) {
            self.init()
            self.status = status
            self.packageName = packageName
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
                "eb" : #keyPath(status),
                "ea" : #keyPath(packageName),
                "ee" : #keyPath(type),
            ]
        }
        
        override var eventKey : String {
            return kPackagePurchaseKey
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
        
        convenience init(actionType: NetmeraEventValues.ContactBackupType, status: NetmeraEventValues.GeneralStatus) {
            self.init(action: actionType.text, status: status.text)
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
                 .application(.pdf), .application(.ppt), .application(.pptx),
                 .application(.usdz), .allDocs:
                acceptableType = .document
            case .audio:
                acceptableType = .music
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
    
    
    final class BackgroundSync: NetmeraEvent {
        
        enum BackgroundSyncType {
            
            case locationChange
            case backgroundTask(type: String)
            
            var description: String {
                switch self {
                case .locationChange:
                    return "LocationChange"
                case .backgroundTask(type: let type):
                    return "BackgroundTask(\(type))"
                }
            }
        }
        
        private let kBackgroundSyncKey = "goa"
        @objc var syncType = ""
        
        convenience init(syncType: BackgroundSyncType) {
            self.init()
            self.syncType = syncType.description
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [
                "ea" : #keyPath(syncType),
            ]
        }
        
        override var eventKey : String {
            return kBackgroundSyncKey
        }
    }
    
    final class AddToFavorites: NetmeraEvent {
        private let key = "mzf"
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
            return key
        }
    }
    
    final class RemoveFromAlbum: NetmeraEvent {
        private let key = "wts"
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
            return key
        }
    }
    
    final class PlusButton: NetmeraEvent {
        private let key = "xoy"
        @objc var action = ""
        
        convenience init?(action: TabBarViewController.Action) {
            let netmeraPussButtonAction: NetmeraEventValues.PlusButtonAction
            switch action {
            case .createFolder:
                netmeraPussButtonAction = .newFolder
            case .upload:
                netmeraPussButtonAction = .upload
            case .uploadFiles:
                netmeraPussButtonAction = .uploadFiles
            case .uploadDocuments:
                netmeraPussButtonAction = .uploadFiles
            case .uploadMusic:
                netmeraPussButtonAction = .uploadMusic
            case .uploadFromApp:
                netmeraPussButtonAction = .uploadFromLifebox
            default:
                return nil
            }
            self.init(action: netmeraPussButtonAction)
        }
        
        convenience init(action: NetmeraEventValues.PlusButtonAction) {
            self.init()
            self.action = action.text
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return[
                "ea" : #keyPath(action),
            ]
        }
        
        override var eventKey : String {
            return key
        }
    }
    
    final class Search: NetmeraEvent {
        private let key = "rki"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return[:]
        }
        
        override var eventKey : String {
            return key
        }
    }
    
    final class VideoDisplayed: NetmeraEvent {
        private let key = "zcd"
       
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return[:]
        }
        
        override var eventKey : String {
            return key
        }
    }
    
    final class PeriodicContactSync: NetmeraEvent {
        private let key = "dak"
        @objc var action = ""
        @objc var type = ""
        
        convenience init(action: NetmeraEventValues.OnOffSettings, type: NetmeraEventValues.PeriodicContactSyncType?) {
            self.init()
            self.action = action.text
            self.type = type?.text ?? ""
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return[
                "ea" : #keyPath(action),
                "eb" : #keyPath(type),
            ]
        }
        override var eventKey : String {
            return key
        }
    }
    
    final class PhotoEditApplyAdjustment: NetmeraEvent {
        private let key = "mov"
        @objc var selection = ""
        @objc var filterType = ""
        @objc var action = ""

        convenience init(selection: NetmeraEventValues.PhotoEditAdjustmentType, filterType: String, action: NetmeraEventValues.PhotoEditActionType) {
            self.init()
            self.selection = selection.text
            self.filterType = filterType
            self.action = action.text
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return[
                "ea" : #keyPath(selection),
                "eb" : #keyPath(filterType),
                "ee" : #keyPath(action)
            ]
        }
        
        override var eventKey : String {
            return key
        }
    }
    
    final class PhotoEditApplyFilter: NetmeraEvent {
        private let key = "cdw"
        @objc var filterType = ""
        @objc var action = ""

        convenience init(filterType: String, action: NetmeraEventValues.PhotoEditActionType) {
            self.init()
            self.filterType = filterType
            self.action = action.text
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return[
                "ea" : #keyPath(filterType),
                "eb" : #keyPath(action)
            ]
        }
        
        override var eventKey : String {
            return key
        }
    }
    
    final class PhotoEditComplete: NetmeraEvent {
        private let key = "nsg"
        @objc var status = ""
        @objc var selection = ""

        convenience init(status: NetmeraEventValues.GeneralStatus, selection: NetmeraEventValues.PhotoEditType) {
            self.init()
            self.status = status.text
            self.selection = selection.text
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return[
                "ea" : #keyPath(status),
                "eb" : #keyPath(selection)
            ]
        }
        
        override var eventKey : String {
            return key
        }
    }
    
    final class PhotoEditButtonAction: NetmeraEvent {
        private let key = "jpj"
        @objc var buttonName = ""

        convenience init(buttonName: NetmeraEventValues.PhotoEditButton) {
            self.init()
            self.buttonName = buttonName.text
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return[
                "ea" : #keyPath(buttonName)
            ]
        }
        
        override var eventKey : String {
            return key
        }
    }
    
    final class SeeAllSharedEvent: NetmeraEvent {
        private let key = "wpr"
        
        override var eventKey : String {
            return key
        }
    }
    
    final class EndShareEvent: NetmeraEvent {
        private let key = "xay"
        
        override var eventKey : String {
            return key
        }
    }
    
    final class LeaveShareEvent: NetmeraEvent {
        private let key = "zvw"
        
        override var eventKey : String {
            return key
        }
    }

}
