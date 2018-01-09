//
//  SyncServiceManager.swift
//  Depo_LifeTech
//
//  Created by Konstantin on 12/14/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import Reachability


class SyncServiceManager {
    static let shared = SyncServiceManager()
    
    private let reachabilityService = Reachability()
    private let autoSyncStorage = AutoSyncDataStorage()
    
    private let photoSyncService: ItemSyncService = PhotoSyncService()
    private let videoSyncService: ItemSyncService = VideoSyncService()
    private var settings: SettingsAutoSyncModel?
    
    private var lastAutoSyncTime: TimeInterval = 0
    private var timeIntervalBetweenSyncs: TimeInterval = NumericConstants.timeIntervalBetweenAutoSync
    
    private var isSyncCancelled: Bool {
        return (photoSyncService.status == .canceled && videoSyncService.status == .canceled)
    }
    
    private var hasPrepairingSync: Bool {
        return (photoSyncService.status == .prepairing || videoSyncService.status == .prepairing)
    }
    
    private var hasExecutingSync: Bool {
        return (photoSyncService.status == .executing || videoSyncService.status == .executing)
    }
    
    private var hasWaitingForWiFiSync: Bool {
        return (photoSyncService.status == .waitingForWifi || videoSyncService.status == .waitingForWifi)
    }
    
    
    //MARK: - Init
    
    init() {
        photoSyncService.delegate = self
        videoSyncService.delegate = self
        setupReachability()
        setupAPIReachability()
        subscribeForNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: - Public
    
    func updateSyncSettings(settingsModel: SettingsAutoSyncModel) {
        log.debug("SyncServiceManager updateSyncSettings")
        
        settings = settingsModel
    
        checkReachabilityAndSettings()
    }
    
    func updateImmediately() {
        log.debug("SyncServiceManager updateImmediately")

        lastAutoSyncTime = NSDate().timeIntervalSince1970
        
        checkReachabilityAndSettings()
    }
    
    func updateInBackground() {
        log.debug("SyncServiceManager updateInBackground")

        let time = NSDate().timeIntervalSince1970
        if time - lastAutoSyncTime > timeIntervalBetweenSyncs {
            lastAutoSyncTime = time
            
            checkReachabilityAndSettings()
        }
    }
    
    
    //MARK: - Private
    
    private func setupAPIReachability() {
        APIReachabilityService.shared.startNotifier()
    }
    
    private func setupReachability() {
        guard let reachability = reachabilityService else {
            return
        }
        
        do {
           try reachability.startNotifier()
        } catch {
            print("\(#function): can't start reachability notifier")
        }
        
        reachability.whenReachable = { (reachability) in
            print("AUTOSYNC: is reachable")
            self.checkReachabilityAndSettings()
        }
        
        reachability.whenUnreachable = { (reachability) in
            print("AUTOSYNC: is unreachable")
            self.checkReachabilityAndSettings()
        }
    }
    
    private func checkReachabilityAndSettings() {
        guard let syncSettings = settings else {
            AutoSyncDataStorage().getAutoSyncModelForCurrentUser(success: { [weak self] (autoSyncModels, _) in
                if let `self` = self {
                    let settings = SettingsAutoSyncModel()
                    settings.isAutoSyncEnable = autoSyncModels[SettingsAutoSyncModel.autoSyncEnableIndex].isSelected
                    settings.mobileDataPhotos = autoSyncModels[SettingsAutoSyncModel.mobileDataPhotosIndex].isSelected
                    settings.mobileDataVideo = autoSyncModels[SettingsAutoSyncModel.mobileDataVideoIndex].isSelected
                    
                    self.updateSyncSettings(settingsModel: settings)
                }
            })
            
            return
        }
        
        timeIntervalBetweenSyncs = NumericConstants.timeIntervalBetweenAutoSync
        
        guard syncSettings.isAutoSyncEnable else {
            stop(reachabilityDidChange: false, photo: true, video: true)
            CardsManager.default.startOperationWith(type: .autoUploadIsOff, allOperations: nil, completedOperations: nil)
            return
        }
        
        CardsManager.default.stopOperationWithType(type: .autoUploadIsOff)
        
        guard let reachability = reachabilityService else {
            print("\(#function): reachabilityService is nil")
            return
        }
        
        if reachability.connection != .none, APIReachabilityService.shared.connection == .reachable {
            if reachability.connection == .wifi {
                start(photo: true, video: true)
            } else if reachability.connection == .cellular {
                let photoEnabled = syncSettings.mobileDataPhotos
                let videoEnabled = syncSettings.mobileDataVideo
                if photoEnabled || videoEnabled {
                    start(photo: photoEnabled, video: videoEnabled)
                }
                stop(reachabilityDidChange: true, photo: !photoEnabled, video: !videoEnabled)
            }
        } else {
            stop(reachabilityDidChange: true, photo: true, video: true)
        }
    }
    
    //MARK: Flow

    //start to sync
    private func start(photo: Bool, video: Bool) {
        if photo { photoSyncService.start() }
        if video { videoSyncService.start() }
    }
    
    //stop/cancel completely
    private func stop(reachabilityDidChange: Bool, photo: Bool, video: Bool) {
        if reachabilityDidChange {
            if photo { photoSyncService.interrupt() }
            if video { videoSyncService.interrupt() }
        } else {
            if photo { photoSyncService.stop() }
            if video { videoSyncService.stop() }
        }
    }
}



//MARK: - Notifications
extension SyncServiceManager {
    private func subscribeForNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(onPhotoLibraryDidChange),
                                       name: NSNotification.Name(rawValue: LocalMediaStorage.notificationPhotoLibraryDidChange),
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(onAutoSyncStatusDidChange),
                                       name: autoSyncStatusDidChangeNotification,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(onAPIReachabilityDidChange),
                                       name: APIReachabilityService.APIReachabilityDidChangeName,
                                       object: nil)
    }
    
    @objc private func onPhotoLibraryDidChange() {
        checkReachabilityAndSettings()
    }
    
    @objc private func onAPIReachabilityDidChange() {
        checkReachabilityAndSettings()
    }
    
    @objc private func onAutoSyncStatusDidChange() {
        if isSyncCancelled {
            CardsManager.default.stopOperationWithType(type: .waitingForWiFi)
            CardsManager.default.stopOperationWithType(type: .prepareToAutoSync)
            CardsManager.default.stopOperationWithType(type: .sync)
            return
        }
        
        if hasExecutingSync {
            CardsManager.default.stopOperationWithType(type: .waitingForWiFi)
            CardsManager.default.stopOperationWithType(type: .prepareToAutoSync)
            return
        }
        
        if hasPrepairingSync {
            CardsManager.default.stopOperationWithType(type: .waitingForWiFi)
            CardsManager.default.startOperationWith(type: .prepareToAutoSync, allOperations: nil, completedOperations: nil)
            return
        }

        if hasWaitingForWiFiSync {
            CardsManager.default.startOperationWith(type: .waitingForWiFi, allOperations: nil, completedOperations: nil)
        }
    }
}


//MARK: - ItemSyncServiceDelegate

extension SyncServiceManager: ItemSyncServiceDelegate {
    func didReceiveOutOfSpaceError() {
        stop(reachabilityDidChange: false, photo: true, video: true)
        if UIApplication.shared.applicationState == .background {
            timeIntervalBetweenSyncs = NumericConstants.timeIntervalBetweenAutoSyncAfterOutOfSpaceError
        }
        showOutOfSpaceAlert()
    }
    
    func didReceiveError() {
        stop(reachabilityDidChange: false, photo: true, video: true)
    }
}


extension SyncServiceManager {
    fileprivate func showOutOfSpaceAlert() {
        let controller = PopUpController.with(title: TextConstants.syncOutOfSpaceAlertTitle,
                                              message: TextConstants.syncOutOfSpaceAlertText,
                                              image: .none,
                                              firstButtonTitle: TextConstants.syncOutOfSpaceAlertCancel,
                                              secondButtonTitle: TextConstants.syncOutOfSpaceAlertGoToSettings,
                                              secondAction: { vc in
                                                vc.close(completion: {
                                                    let router = RouterVC()
                                                    router.pushViewController(viewController: router.packages)
                                                })
        })
        UIApplication.topController()?.present(controller, animated: false, completion: nil)
    }
}






