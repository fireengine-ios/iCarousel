//
//  SyncServiceManger.swift
//  Depo_LifeTech
//
//  Created by Konstantin on 12/14/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import ReachabilitySwift


class SyncServiceManger {
    static let shared = SyncServiceManger()
    
    fileprivate let reachabilityService = ReachabilityService()
    
    fileprivate let photoSyncService: ItemSyncService = PhotoSyncService()
    fileprivate let videoSyncService: ItemSyncService = VideoSyncService()
    fileprivate var settings: SettingsAutoSyncModel?
    
    private var lastAutoSyncTime: TimeInterval = 0
    
    private var hasExecutingSync: Bool {
        return (photoSyncService.status == .executing || videoSyncService.status == .executing)
    }
    
    private var hasWaitingForWiFiSync: Bool {
        return (photoSyncService.status == .waitingForWifi || videoSyncService.status == .waitingForWifi)
    }
    
    
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
    
        checkReachabilityAndSettings()
    }
    
    func updateImmediately() {
        lastAutoSyncTime = NSDate().timeIntervalSince1970
        
        checkReachabilityAndSettings()
    }
    
    func updateInBackground() {
        let time = NSDate().timeIntervalSince1970
        if time - lastAutoSyncTime > NumericConstants.timeIntervalBetweenAutoSync{
            lastAutoSyncTime = time
            
            checkReachabilityAndSettings()
        }
    }
    
    
    func syncWithDataPlan() {
        startManually()
    }
    
    
    //MARK: - Private
    
    fileprivate func checkReachabilityAndSettings() {
        guard let syncSettings = settings else {
            print("\(#function): Auto sync settings are missing")
            return
        }
        
        guard syncSettings.isAutoSyncEnable else {
            WrapItemOperatonManager.default.startOperationWith(type: .autoUploadIsOff, allOperations: nil, completedOperations: nil)
            stop(reachabilityDidChange: false)
            return
        }
        
        WrapItemOperatonManager.default.stopOperationWithType(type: .autoUploadIsOff)
        
        if reachabilityService.isReachable {
            if reachabilityService.isReachableViaWiFi {
                start(photo: true, video: true)
            } else {
                start(photo: syncSettings.mobileDataPhotos, video: syncSettings.mobileDataVideo)
            }
        } else {
            stop(reachabilityDidChange: true)
        }
    }
    
    //MARK: Flow

    //start to sync
    fileprivate func start(photo: Bool, video: Bool) {
        WrapItemOperatonManager.default.startOperationWith(type: .prepareToAutoSync, allOperations: nil, completedOperations: nil)
        
        if photo { photoSyncService.start() }
        if video { videoSyncService.start() }
    }
    
    //stop/cancel completely
    fileprivate func stop(reachabilityDidChange: Bool) {
        if reachabilityDidChange {
            photoSyncService.interrupt()
            videoSyncService.interrupt()
        } else {
            photoSyncService.stop()
            videoSyncService.stop()
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
extension SyncServiceManger {
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
        
        notificationCenter.addObserver(self,
                                       selector: #selector(onAutoSyncStatusDidChange),
                                       name: autoSyncStatusDidChangeNotification,
                                       object: nil)
    }
    
    @objc private func onPhotoLibraryDidChange() {
        checkReachabilityAndSettings()
    }
    
    @objc private func onReachabilityDidChange() {
        checkReachabilityAndSettings()
    }
    
    @objc private func onAutoSyncStatusDidChange() {
        WrapItemOperatonManager.default.stopOperationWithType(type: .prepareToAutoSync)
        
        if !hasExecutingSync, hasWaitingForWiFiSync {
            WrapItemOperatonManager.default.startOperationWith(type: .waitingForWiFi, allOperations: nil, completedOperations: nil)
        }
    }
}







