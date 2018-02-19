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
    
    private let dispatchQueue = DispatchQueue(label: "com.lifebox.autosync")
    
    private let reachabilityService = Reachability()
    
    private lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
//        queue.underlyingQueue = dispatchQueue
        return queue
    }()
    
    private let photoSyncService: ItemSyncService = PhotoSyncService()
    private let videoSyncService: ItemSyncService = VideoSyncService()
    private var settings: SettingsAutoSyncModel?
    
    private var lastAutoSyncTime: TimeInterval = 0
    private var timeIntervalBetweenSyncs: TimeInterval = NumericConstants.timeIntervalBetweenAutoSync
    
    
    private var isSyncStoped: Bool {
        return (photoSyncService.status == .stoped && videoSyncService.status == .stoped)
    }
    
    private var isSyncFailed: Bool {
        return (photoSyncService.status == .failed && videoSyncService.status == .failed)
    }
    
    private var isSyncFinished: Bool {
        return (photoSyncService.status == .synced && videoSyncService.status == .synced)
    }
    
    private var hasSyncStoped: Bool {
        return (photoSyncService.status == .stoped || videoSyncService.status == .stoped)
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
    
    private var hasFailedSync: Bool {
        return (photoSyncService.status == .failed || videoSyncService.status == .failed)
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
    
        checkReachabilityAndSettings(reachabilityChanged: false, newItems: false)
    }
    
    func updateImmediately() {
        log.debug("SyncServiceManager updateImmediately")

        lastAutoSyncTime = NSDate().timeIntervalSince1970
        
        checkReachabilityAndSettings(reachabilityChanged: false, newItems: false)
    }
    
    func updateInBackground() {
        log.debug("SyncServiceManager updateInBackground")

        let time = NSDate().timeIntervalSince1970
        if time - lastAutoSyncTime > timeIntervalBetweenSyncs {
            lastAutoSyncTime = time
            log.debug("Sync should start in bacground")
            checkReachabilityAndSettings(reachabilityChanged: false, newItems: false)
        }
    }
    
    func stopSync() {
        operationQueue.cancelAllOperations()
        stop(reachabilityDidChange: false, photo: true, video: true)
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
            self.checkReachabilityAndSettings(reachabilityChanged: true, newItems: false)
        }
        
        reachability.whenUnreachable = { (reachability) in
            print("AUTOSYNC: is unreachable")
            self.checkReachabilityAndSettings(reachabilityChanged: true, newItems: false)
        }
    }
    
    private func checkReachabilityAndSettings(reachabilityChanged: Bool, newItems: Bool) {
        dispatchQueue.async {
            guard let syncSettings = self.settings else {
                AutoSyncDataStorage().getAutoSyncModelForCurrentUser(success: { [weak self] (autoSyncModels, _) in
                    if let `self` = self {
                        let settings = SettingsAutoSyncModel()
                        settings.isAutoSyncEnable = autoSyncModels[SettingsAutoSyncModel.autoSyncEnableIndex].isSelected
                        settings.mobileDataPhotos = autoSyncModels[SettingsAutoSyncModel.mobileDataPhotosIndex].isSelected
                        settings.mobileDataVideo = autoSyncModels[SettingsAutoSyncModel.mobileDataVideoIndex].isSelected
                        
                        if self.settings == nil {
                            self.updateSyncSettings(settingsModel: settings)
                        }
                    }
                })
                
                return
            }
            
            self.timeIntervalBetweenSyncs = NumericConstants.timeIntervalBetweenAutoSync
            
            guard syncSettings.isAutoSyncEnable else {
                self.stop(reachabilityDidChange: false, photo: true, video: true)
                CardsManager.default.startOperationWith(type: .autoUploadIsOff, allOperations: nil, completedOperations: nil)
                return
            }
            
            CardsManager.default.stopOperationWithType(type: .autoUploadIsOff)
            
            guard let reachability = self.reachabilityService else {
                print("\(#function): reachabilityService is nil")
                return
            }
            
            if reachability.connection != .none, APIReachabilityService.shared.connection != .unreachable {
                if reachability.connection == .wifi {
                    self.start(photo: true, video: true, newItems: newItems)
                } else if reachability.connection == .cellular {
                    let photoEnabled = syncSettings.mobileDataPhotos
                    let videoEnabled = syncSettings.mobileDataVideo
                    
                    self.stop(reachabilityDidChange: true, photo: !photoEnabled, video: !videoEnabled)
                    if photoEnabled || videoEnabled {
                        self.start(photo: photoEnabled, video: videoEnabled, newItems: newItems)
                    }
                }
            } else {
                self.stop(reachabilityDidChange: reachabilityChanged, photo: true, video: true)
            }
        }
    }
    
    //MARK: Flow

    //start to sync
    private func start(photo: Bool, video: Bool, newItems: Bool) {
        operationQueue.cancelAllOperations()
        
        if photo {
            let operation = ItemSyncOperation(service: photoSyncService, newItems: newItems)
            operationQueue.addOperation(operation)
        }
        
        if video {
            let operation = ItemSyncOperation(service: videoSyncService, newItems: newItems)
            operationQueue.addOperation(operation)
        }
    }
    
    //stop/cancel completely
    private func stop(reachabilityDidChange: Bool, photo: Bool, video: Bool) {
        operationQueue.cancelAllOperations()
        
        if reachabilityDidChange {
            if photo { photoSyncService.waitForWiFi() }
            if video { videoSyncService.waitForWiFi() }
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
                                       selector: #selector(onPhotoLibraryDidChange(notification:)),
                                       name: LocalMediaStorage.notificationPhotoLibraryDidChange,
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
    
    @objc private func onPhotoLibraryDidChange(notification: Notification) {
        if let phChanges = notification.userInfo {
            if let _ = phChanges[PhotoLibraryChangeType.added] as? [PHAsset]  {
                //TODO: append only added items
                 checkReachabilityAndSettings(reachabilityChanged: false, newItems: true)
            }
        }
    }
    
    @objc private func onAPIReachabilityDidChange() {
        self.checkReachabilityAndSettings(reachabilityChanged: true, newItems: false)
    }
    
    @objc private func onAutoSyncStatusDidChange() {
        if hasExecutingSync {
            CardsManager.default.stopOperationWithType(type: .waitingForWiFi)
            CardsManager.default.stopOperationWithType(type: .prepareToAutoSync)
            WidgetService.shared.notifyWidgetAbout(status: .executing)
            return
        }
        
        CardsManager.default.stopOperationWithType(type: .sync)
        FreeAppSpace.default.checkFreeAppSpaceAfterAutoSync()
        ItemOperationManager.default.syncFinished()
        WidgetService.shared.notifyWidgetAbout(status: .stoped)
        
        if hasPrepairingSync {
            CardsManager.default.startOperationWith(type: .prepareToAutoSync, allOperations: nil, completedOperations: nil)
            CardsManager.default.stopOperationWithType(type: .waitingForWiFi)
            return
        }
        
        CardsManager.default.stopOperationWithType(type: .prepareToAutoSync)
        
        if hasWaitingForWiFiSync {
            CardsManager.default.startOperationWith(type: .waitingForWiFi, allOperations: nil, completedOperations: nil)
            return
        }
        
        CardsManager.default.stopOperationWithType(type: .waitingForWiFi)
        
        if isSyncStoped || isSyncFailed || isSyncFinished {
            //TODO: show error?
            return
        }
        
        if hasFailedSync || hasSyncStoped {
            //TODO: show error?
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






