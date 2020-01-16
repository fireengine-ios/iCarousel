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
    @objc var photopickLeftAnalysis = ""
    @objc var lifeboxStorage: Int = 0
    @objc var faceImageGrouping = ""
    @objc var accountType = ""
    @objc var twoFactorAuthentication = ""
    @objc var autosync = ""
    @objc var emailVerification = ""
    @objc var autosyncPhotos = ""
    @objc var packages = [String]()
    @objc var autoLogin = ""
    @objc var autosyncVideos = ""
    @objc var turkcellPassword = ""
    
    convenience init(deviceStorage: Int, photopickLeftAnalysis: NetmeraEventValues.PhotopickUserAnalysisLeft,
                     lifeboxStorage: Int, faceImageGrouping: NetmeraEventValues.OnOffSettings,
                     accountType: String, twoFactorAuthentication: NetmeraEventValues.OnOffSettings,
                     autosync: NetmeraEventValues.OnOffSettings, emailVerification: NetmeraEventValues.OnOffSettings,
                     autosyncPhotos: NetmeraEventValues.AutoSyncState, autosyncVideos: NetmeraEventValues.AutoSyncState,
                     packages: [String], autoLogin: NetmeraEventValues.OnOffSettings,
                     turkcellPassword: NetmeraEventValues.OnOffSettings) {
        self.init()
        self.deviceStorage = deviceStorage
        self.photopickLeftAnalysis = photopickLeftAnalysis.text
        self.lifeboxStorage = lifeboxStorage
        self.faceImageGrouping = faceImageGrouping.text
        self.accountType = accountType
        self.twoFactorAuthentication = twoFactorAuthentication.text
        self.autosync = autosync.text
        self.emailVerification = emailVerification.text
        self.autosyncPhotos = autosyncPhotos.text
        self.autosyncVideos = autosyncVideos.text
        self.packages = packages
        self.autoLogin = autoLogin.text
        self.turkcellPassword = turkcellPassword.text
    }
    
    convenience init(deviceStorage: Int, photopickLeftAnalysis: String,
                     lifeboxStorage: Int, faceImageGrouping: String,
                     accountType: String, twoFactorAuthentication: String,
                     autosync: String, emailVerification: String,
                     autosyncPhotos: String, autosyncVideos: String,
                     packages: [String], autoLogin: String,
                     turkcellPassword: String) {
        self.init()
        self.deviceStorage = deviceStorage
        self.photopickLeftAnalysis = photopickLeftAnalysis
        self.lifeboxStorage = lifeboxStorage
        self.faceImageGrouping = faceImageGrouping
        self.accountType = accountType
        self.twoFactorAuthentication = twoFactorAuthentication
        self.autosync = autosync
        self.emailVerification = emailVerification
        self.autosyncPhotos = autosyncPhotos
        self.autosyncVideos = autosyncVideos
        self.packages = packages
        self.autoLogin = autoLogin
        self.turkcellPassword = turkcellPassword
    }

    override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
        return[
            "peb" : #keyPath(deviceStorage),
            "pda" : #keyPath(photopickLeftAnalysis),
            "pea" : #keyPath(lifeboxStorage),
            "pcb" : #keyPath(faceImageGrouping),
            "pdc" : #keyPath(accountType),
            "pdb" : #keyPath(twoFactorAuthentication),
            "pcd" : #keyPath(autosync),
            "pde" : #keyPath(emailVerification),
            "pcc" : #keyPath(autosyncPhotos),
            "pdd" : #keyPath(packages),
            "pdg" : #keyPath(autoLogin),
            "pce" : #keyPath(autosyncVideos),
            "pdf" : #keyPath(turkcellPassword),
        ]
    }
}
