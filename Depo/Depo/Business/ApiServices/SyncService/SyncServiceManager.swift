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
    
    private let dispatchQueue = DispatchQueue(label: DispatchQueueLabels.autosync)
    
    private let reachabilityService = Reachability()
    
    private lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private let photoSyncService: ItemSyncService = PhotoSyncService()
    private let videoSyncService: ItemSyncService = VideoSyncService()
    private var settings = AutoSyncDataStorage().settings
    
    private var lastAutoSyncTime: TimeInterval = 0
    private var timeIntervalBetweenSyncsInBackground: TimeInterval = NumericConstants.timeIntervalBetweenAutoSyncInBackground
    
    
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
        if time - lastAutoSyncTime > timeIntervalBetweenSyncsInBackground {
            lastAutoSyncTime = time
            log.debug("Sync should start in background")
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
        print("AUTOSYNC: checkReachabilityAndSettings")
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.timeIntervalBetweenSyncsInBackground = NumericConstants.timeIntervalBetweenAutoSyncInBackground
            
            guard self.settings.isAutoSyncEnabled else {
                self.stopSync()
                CardsManager.default.startOperationWith(type: .autoUploadIsOff, allOperations: nil, completedOperations: nil)
                MenloworksEventsService.shared.onAutosyncOff()
                return
            }
            
            CardsManager.default.stopOperationWithType(type: .autoUploadIsOff)
            
            guard !CoreDataStack.default.inProcessAppendingLocalFiles else {
                CardsManager.default.startOperationWith(type: .prepareToAutoSync, allOperations: nil, completedOperations: nil)
                return
            }
            
            guard let reachability = self.reachabilityService else {
                print("\(#function): reachabilityService is nil")
                return
            }
            
            let photoOption = self.settings.photoSetting.option
            let videoOption = self.settings.videoSetting.option
            let serverIsReachable = (reachability.connection != .none && APIReachabilityService.shared.connection != .unreachable)
            
            if serverIsReachable {
                let photoEnabled = (reachability.connection == .wifi && photoOption.isContained(in: [.wifiOnly, .wifiAndCellular])) ||
                    (reachability.connection == .cellular && photoOption == .wifiAndCellular)
                
                let videoEnabled = (reachability.connection == .wifi && videoOption.isContained(in: [.wifiOnly, .wifiAndCellular])) ||
                    (reachability.connection == .cellular && videoOption == .wifiAndCellular)
                
                let photoServiceWaitingForWiFi = reachability.connection == .cellular && photoOption == .wifiOnly
                let videoServiceWaitingForWiFi = reachability.connection == .cellular && videoOption == .wifiOnly
                
                let shoudStopPhotoSync = !photoEnabled && !photoServiceWaitingForWiFi
                let shouldStopVideoSync = !videoEnabled && !videoServiceWaitingForWiFi
                
                self.stop(photo: shoudStopPhotoSync, video: shouldStopVideoSync)
                self.waitForWifi(photo: photoServiceWaitingForWiFi, video: videoServiceWaitingForWiFi)
                self.start(photo: photoEnabled, video: videoEnabled, newItems: newItems)
            } else {
                let photoServiceWaitingForWiFi = photoOption.isContained(in: [.wifiOnly, .wifiAndCellular])
                let videoServiceWaitingForWiFi = videoOption.isContained(in: [.wifiOnly, .wifiAndCellular])
                
                self.stop(photo: !photoServiceWaitingForWiFi, video: !videoServiceWaitingForWiFi)
                self.waitForWifi(photo: photoServiceWaitingForWiFi, video: videoServiceWaitingForWiFi)
            }
        }
    }
    
    // MARK: Flow

    //start to sync
    private func start(photo: Bool, video: Bool, newItems: Bool) {
        if photo || video {
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
    }
    
    //stop/cancel completely
    private func waitForWifi(photo: Bool, video: Bool) {
        if photo || video {
            operationQueue.cancelAllOperations()
            
            if photo { photoSyncService.waitForWiFi() }
            if video { videoSyncService.waitForWiFi() }
        }
    }
    
    private func stop(photo: Bool, video: Bool) {
        if photo || video {
            operationQueue.cancelAllOperations()
            
            if photo { photoSyncService.stop() }
            if video { videoSyncService.stop() }
        }
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
        
        notificationCenter.addObserver(self,
                                       selector: #selector(onLocalFilesHaveBeenLoaded),
                                       name: Notification.Name.allLocalMediaItemsHaveBeenLoaded,
                                       object: nil)
    }
    
    @objc private func onPhotoLibraryDidChange(notification: Notification) {
        if let phChanges = notification.userInfo {
            if let _ = phChanges[PhotoLibraryChangeType.added] as? [PHAsset] {
                //TODO: append only added items
                checkReachabilityAndSettings(reachabilityChanged: false, newItems: true)
            } else {
                checkReachabilityAndSettings(reachabilityChanged: false, newItems: false)
            }
        }
    }
    
    @objc private func onAPIReachabilityDidChange() {
        self.checkReachabilityAndSettings(reachabilityChanged: true, newItems: false)
    }
    
    @objc private func onLocalFilesHaveBeenLoaded() {
        self.checkReachabilityAndSettings(reachabilityChanged: false, newItems: false)
    }
    
    @objc private func onAutoSyncStatusDidChange() {
        if hasExecutingSync {
            CardsManager.default.stopOperationWithType(type: .waitingForWiFi)
            CardsManager.default.stopOperationWithType(type: .prepareToAutoSync)
            WidgetService.shared.notifyWidgetAbout(status: .executing)
            return
        }
    
        CardsManager.default.stopOperationWithType(type: .sync)
        
        ItemOperationManager.default.syncFinished()
        WidgetService.shared.notifyWidgetAbout(status: .stoped)
        
        if hasPrepairingSync {
            CardsManager.default.startOperationWith(type: .prepareToAutoSync, allOperations: nil, completedOperations: nil)
            CardsManager.default.stopOperationWithType(type: .waitingForWiFi)
            return
        }
        
        CardsManager.default.stopOperationWithType(type: .prepareToAutoSync)
        
        FreeAppSpace.default.checkFreeAppSpaceAfterAutoSync()
        ItemOperationManager.default.syncFinished()
        WidgetService.shared.notifyWidgetAbout(status: .stoped)
        
        if hasWaitingForWiFiSync {
            CardsManager.default.startOperationWith(type: .waitingForWiFi, allOperations: nil, completedOperations: nil)
            return
        }
        
        CardsManager.default.stopOperationWithType(type: .waitingForWiFi)
    }
}


// MARK: - ItemSyncServiceDelegate

extension SyncServiceManager: ItemSyncServiceDelegate {
    func didReceiveOutOfSpaceError() {
        stopSync()
        if UIApplication.shared.applicationState == .background {
            timeIntervalBetweenSyncsInBackground = NumericConstants.timeIntervalBetweenAutoSyncAfterOutOfSpaceError
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
