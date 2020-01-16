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
    @objc var storage = ""
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
                     accountType: String, storage: String, twoFactorAuthentication: NetmeraEventValues.OnOffSettings,
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
        self.storage = storage
        self.twoFactorAuthentication = twoFactorAuthentication.text
        self.autosync = autosync.text
        self.emailVerification = emailVerification.text
        self.autosyncPhotos = autosyncPhotos.text
        self.autosyncVideos = autosyncVideos.text
        self.packages = packages
        self.autoLogin = autoLogin.text
        self.turkcellPassword = turkcellPassword.text
    }

    override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
        return[
            "peb" : #keyPath(deviceStorage),
            "pda" : #keyPath(photopickLeftAnalysis),
            "pea" : #keyPath(lifeboxStorage),
            "pcb" : #keyPath(faceImageGrouping),
            "pdc" : #keyPath(accountType),
            "pca" : #keyPath(storage),
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
