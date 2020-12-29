//
//  NetmeraCustomUser.swift
//  Depo
//
//  Created by Alex Developer on 16.01.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

final class NetmeraCustomUser: NetmeraUser {

    @objc var deviceStorage: Int = 0
    @objc var lifeboxStorage: Int = 0
    @objc var accountType = ""
    @objc var twoFactorAuthentication = ""
    @objc var autosync = ""
    @objc var emailVerification = ""
    @objc var autosyncPhotos = ""
    @objc var autoLogin = ""
    @objc var turkcellPassword = ""
    @objc var buildNumber = ""
    @objc var countryCode = ""
    @objc var regionCode = ""
    @objc var isUserName: Int = 0
    @objc var isUserSurname: Int = 0
    @objc var isEmail: Int = 0
    @objc var isPhoneNumber: Int = 0
    @objc var isAddress: Int = 0
    @objc var isBirthDay: Int = 0
    @objc var galleryAccessPermission: String = ""
    
    
    convenience init(deviceStorage: Int, lifeboxStorage: Int, accountType: String, twoFactorAuthentication: NetmeraEventValues.OnOffSettings,
                     emailVerification: NetmeraEventValues.OnOffSettings, autoLogin: NetmeraEventValues.OnOffSettings,
                     turkcellPassword: NetmeraEventValues.OnOffSettings, buildNumber: String, countryCode: String, regionCode: String,
                     isUserName: Int, isUserSurname: Int, isEmail: Int, isPhoneNumber: Int, isAddress: Int,
                     isBirthDay: Int, galleryAccessPermission: String) {
        self.init()
        self.deviceStorage = deviceStorage
        self.lifeboxStorage = lifeboxStorage
        self.accountType = accountType
        self.twoFactorAuthentication = twoFactorAuthentication.text
        self.emailVerification = emailVerification.text
        self.autoLogin = autoLogin.text
        self.turkcellPassword = turkcellPassword.text
        self.buildNumber = buildNumber
        self.countryCode = countryCode
        self.regionCode = regionCode
        self.isUserName = isUserName
        self.isUserSurname = isUserSurname
        self.isEmail = isEmail
        self.isPhoneNumber = isPhoneNumber
        self.isAddress = isAddress
        self.isBirthDay = isBirthDay
        self.galleryAccessPermission = galleryAccessPermission
    }
    
    convenience init(deviceStorage: Int, lifeboxStorage: Int,
                     accountType: String, twoFactorAuthentication: String,
                     emailVerification: String, autoLogin: String,
                     turkcellPassword: String, buildNumber: String,
                     countryCode: String, regionCode: String,
                     isUserName: Int, isUserSurname: Int,
                     isEmail: Int, isPhoneNumber: Int,
                     isAddress: Int, isBirthDay: Int,
                     galleryAccessPermission: String) {
        self.init()
        self.deviceStorage = deviceStorage
        self.lifeboxStorage = lifeboxStorage
        self.accountType = accountType
        self.twoFactorAuthentication = twoFactorAuthentication
        self.emailVerification = emailVerification
        self.autoLogin = autoLogin
        self.turkcellPassword = turkcellPassword
        self.buildNumber = buildNumber
        self.countryCode = countryCode
        self.regionCode = regionCode
        self.isUserName = isUserName
        self.isUserSurname = isUserSurname
        self.isEmail = isEmail
        self.isPhoneNumber = isPhoneNumber
        self.isAddress = isAddress
        self.isBirthDay = isBirthDay
        self.galleryAccessPermission = galleryAccessPermission
    }

    override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
        return[
            "peb" : #keyPath(deviceStorage),
            "pea" : #keyPath(lifeboxStorage),
            "pdc" : #keyPath(accountType),
            "pdb" : #keyPath(twoFactorAuthentication),
            "pcd" : #keyPath(autosync),
            "pde" : #keyPath(emailVerification),
            "pdg" : #keyPath(autoLogin),
            "pdf" : #keyPath(turkcellPassword),
            "pdi" : #keyPath(countryCode),
            "zh"  : #keyPath(regionCode),
            "pca" : #keyPath(buildNumber),
            "ped" : #keyPath(isUserName),
            "pec" : #keyPath(isUserSurname),
            "pef" : #keyPath(isEmail),
            "pee" : #keyPath(isPhoneNumber),
            "pcf" : #keyPath(isAddress),
            "pcg" : #keyPath(isBirthDay),
            "bd"  : #keyPath(galleryAccessPermission)
        ]
    }
}
