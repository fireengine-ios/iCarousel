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

        convenience init(status: String, loginType: String) {
            self.init()
            self.status = status
            self.loginType = loginType
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
            return kSignupKey
        }
    }
    
    final class Import: NetmeraEvent {
        
        private let kImportKey = "qfv"
        
        @objc var channelType = ""
        @objc var status = ""
        
        convenience init(status: String, channelType: String) {
            self.init()
            self.status = status
            self.channelType = channelType
        }
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return[
                "ea" : #keyPath(status),
                "eb" : #keyPath(channelType),
            ]
        }
        
        override var eventKey : String {
            return kImportKey
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

        convenience init(action: String) {
            self.init()
            self.action = action
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

        convenience init(uploadType: String, fileType: String) {
            self.init()
            self.uploadType = uploadType
            self.fileType = fileType
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

        convenience init(videos: String, autosyncSetting: String, photos: String) {
            self.init()
            self.videos = videos
            self.autosyncSetting = autosyncSetting
            self.photos = photos
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

        convenience init(action: String) {
            self.init()
            self.action = action
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
            return kAddToAlbumKey
        }
    }
    
    final class Contact: NetmeraEvent {
        
        private let kContactKey = "tda"
        
        @objc var action = ""
        @objc var status = ""
        
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
            return kTrashKey
        }
    }
    
}
