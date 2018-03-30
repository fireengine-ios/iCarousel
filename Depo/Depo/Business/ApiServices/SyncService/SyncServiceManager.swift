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
    private var settings: AutoSyncSettings?
    
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
    
    
    // MARK: - Init
    
    init() {
        photoSyncService.delegate = self
        videoSyncService.delegate = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Public
    func update(syncSettings: AutoSyncSettings) {
        log.debug("SyncServiceManager updateSyncSettings")
        
        subscribeForNotifications()
        
        settings = syncSettings
    
        checkReachabilityAndSettings(reachabilityChanged: false, newItems: false)
    }
    
    func updateImmediately() {
        log.debug("SyncServiceManager updateImmediately")

        subscribeForNotifications()
        
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
        WidgetService.shared.notifyWidgetAbout(status: .stoped)
        stop(photo: true, video: true)
    }
    
    
    // MARK: - Private
    
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

        reachability.whenReachable = { reachability in
            print("AUTOSYNC: is reachable")
            self.checkReachabilityAndSettings(reachabilityChanged: true, newItems: false)
        }
        
        reachability.whenUnreachable = { reachability in
            print("AUTOSYNC: is unreachable")
            self.checkReachabilityAndSettings(reachabilityChanged: true, newItems: false)
        }
    }
    
    private func checkReachabilityAndSettings(reachabilityChanged: Bool, newItems: Bool) {
        dispatchQueue.async {
            guard let syncSettings = self.settings else {
                AutoSyncDataStorage().getAutoSyncSettingsForCurrentUser(success: { [weak self] settings, _ in
                    if let `self` = self {
                        if self.settings == nil {
                            self.update(syncSettings: settings)
                        }
                    }
                })
                
                return
            }
            
            self.timeIntervalBetweenSyncs = NumericConstants.timeIntervalBetweenAutoSync
            
            guard syncSettings.isAutoSyncEnabled else {
                self.stopSync()
                CardsManager.default.startOperationWith(type: .autoUploadIsOff, allOperations: nil, completedOperations: nil)
                MenloworksEventsService.shared.onAutosyncOff()
                return
            }
            
            CardsManager.default.stopOperationWithType(type: .autoUploadIsOff)
            
            guard let reachability = self.reachabilityService else {
                print("\(#function): reachabilityService is nil")
                return
            }
            
            let photoOption = syncSettings.photoSetting.option
            let videoOption = syncSettings.videoSetting.option
            
            if reachability.connection != .none, APIReachabilityService.shared.connection != .unreachable {
                let photoEnabled = (reachability.connection == .wifi && photoOption.isContained(in: [.wifiOnly, .wifiAndCellular])) ||
                    (reachability.connection == .cellular && photoOption == .wifiAndCellular)
                
                let videoEnabled = (reachability.connection == .wifi && videoOption.isContained(in: [.wifiOnly, .wifiAndCellular])) ||
                    (reachability.connection == .cellular && videoOption == .wifiAndCellular)
                
                let photoServiceWaitingForWiFi = reachability.connection == .cellular && photoOption == .wifiOnly
                let videoServiceWaitingForWiFi = reachability.connection == .cellular && videoOption == .wifiOnly
                
                if !photoEnabled || !videoEnabled {
                    self.stop(photo: !photoEnabled, video: !videoEnabled)
                }
                
                if photoServiceWaitingForWiFi || videoServiceWaitingForWiFi {
                    self.waitForWifi(photo: photoServiceWaitingForWiFi, video: videoServiceWaitingForWiFi)
                }
                
                if photoEnabled || videoEnabled {
                    self.start(photo: photoEnabled, video: videoEnabled, newItems: newItems)
                }
            } else {
                if reachabilityChanged {
                    let photoServiceWaitingForWiFi = photoOption.isContained(in: [.wifiOnly, .wifiAndCellular])
                    let videoServiceWaitingForWiFi = videoOption.isContained(in: [.wifiOnly, .wifiAndCellular])
                    self.waitForWifi(photo: photoServiceWaitingForWiFi, video: videoServiceWaitingForWiFi)
                } else {
                    self.stopSync()
                }
            }
        }
    }
    
    // MARK: Flow

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
    private func waitForWifi(photo: Bool, video: Bool) {
        operationQueue.cancelAllOperations()
        
        if photo { photoSyncService.waitForWiFi() }
        if video { videoSyncService.waitForWiFi() }
    }
    
    private func stop(photo: Bool, video: Bool) {
        operationQueue.cancelAllOperations()
        
        if photo { photoSyncService.stop() }
        if video { videoSyncService.stop() }
    }
}


// MARK: - Notifications
extension SyncServiceManager {
    private func subscribeForNotifications() {
        setupReachability()
        setupAPIReachability()
        
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
            if let _ = phChanges[PhotoLibraryChangeType.added] as? [PHAsset] {
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


// MARK: - ItemSyncServiceDelegate

extension SyncServiceManager: ItemSyncServiceDelegate {
    func didReceiveOutOfSpaceError() {
        stopSync()
        if UIApplication.shared.applicationState == .background {
            timeIntervalBetweenSyncs = NumericConstants.timeIntervalBetweenAutoSyncAfterOutOfSpaceError
        }
        showOutOfSpaceAlert()
    }
    
    func didReceiveError() {
        stopSync()
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
                                                    if router.navigationController?.presentedViewController != nil {
                                                        router.pushOnPresentedView(viewController: router.packages)
                                                    } else {
                                                        router.pushViewController(viewController: router.packages)
                                                    }
                                                })
        })
        UIApplication.topController()?.present(controller, animated: false, completion: nil)
    }
}
