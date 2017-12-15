//
//  SyncService.swift
//  Depo_LifeTech
//
//  Created by Konstantin on 12/14/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import ReachabilitySwift


class SyncService {
    static let shared = SyncService()
    
    fileprivate let reachabilityService = ReachabilityService()
    
    fileprivate let photoSyncService: ItemSyncService = PhotoSyncService()
    fileprivate let videoSyncService: ItemSyncService = VideoSyncService()
    fileprivate var settings: SettingsAutoSyncModel?
    
    
    //MARK: - Init
    
    init() {
        subscribeForNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: - Public
    
    func updateSyncSettings(settingsModel: SettingsAutoSyncModel) {
        settings = settingsModel
        
        photoSyncService.isMobileDataEnabled = settingsModel.mobileDataPhotos
        videoSyncService.isMobileDataEnabled = settingsModel.mobileDataVideo
        
        if settingsModel.isAutoSyncEnable {
            photoSyncService.start(mobileData: settingsModel.mobileDataPhotos)
            videoSyncService.start(mobileData: settingsModel.mobileDataVideo)
        } else {
            photoSyncService.stop(mobileDataOnly: false)
            videoSyncService.stop(mobileDataOnly: false)
        }
    }
    
    
    //MARK: - Private
    
    //MARK: Flow
    
    //start to sync
    fileprivate func start(mobileData: Bool) {
        photoSyncService.start(mobileData: mobileData)
        videoSyncService.start(mobileData: mobileData)
    }
    
    //start to sync
    fileprivate func addNewItems(mobileData: Bool) {
        
    }
    
    //stop/cancel completely
    fileprivate func stop(reachabilityDidChange: Bool, mobileDataOnly: Bool) {
        if reachabilityDidChange {
            photoSyncService.interrupt()
            videoSyncService.interrupt()
        } else {
            photoSyncService.stop(mobileDataOnly: mobileDataOnly)
            videoSyncService.stop(mobileDataOnly: mobileDataOnly)
        }
    }
    
    //wait for wi-fi connection
    fileprivate func waitForWiFi() {
        photoSyncService.waitForWiFi()
        videoSyncService.waitForWiFi()
    }
    
    //start if is waiting for wi-fi
    fileprivate func startManually() {
        photoSyncService.startManually()
        videoSyncService.startManually()
    }
}



//MARK: Notifications
extension SyncService {
    fileprivate func subscribeForNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(onPhotoLibraryDidChange),
                                       name: NSNotification.Name(rawValue: LocalMediaStorage.notificationPhotoLibraryDidChange),
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(onReachabilityDidChange),
                                       name: ReachabilityChangedNotification,
                                       object: nil)
    }
    
    @objc private func onPhotoLibraryDidChange() {
        guard let syncSettings = settings else {
            //get
            return
        }
        
        if reachabilityService.isReachable, syncSettings.isAutoSyncEnable {
            start(mobileData: !reachabilityService.isReachableViaWiFi)
        }
    }
    
    @objc private func onReachabilityDidChange() {
        guard let syncSettings = settings else {
            //get
            return
        }
        
        if !reachabilityService.isReachable {
            waitForWiFi()
        } else {
            if syncSettings.isAutoSyncEnable {
                start(mobileData: !reachabilityService.isReachableViaWiFi)
            } else {
                stop(reachabilityDidChange: true, mobileDataOnly: false)
            }
        }
    }
}







