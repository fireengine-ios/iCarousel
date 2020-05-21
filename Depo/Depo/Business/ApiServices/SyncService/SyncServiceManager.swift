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
    
    private let reachabilityService = ReachabilityService.shared
    
    private lazy var coreDataStack: CoreDataStack = factory.resolve()
    
    private lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private var backgroundSyncHandler: BoolHandler?
    
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
    
    var hasExecutingSync: Bool {
        return (photoSyncService.status == .executing || videoSyncService.status == .executing)
    }
    
    private var hasWaitingForWiFiSync: Bool {
        return (photoSyncService.status == .waitingForWifi || videoSyncService.status == .waitingForWifi)
    }
    
    private var hasFailedSync: Bool {
        return (photoSyncService.status == .failed || videoSyncService.status == .failed)
    }
    
    private var newItemsToAppend = SynchronizedArray<PHAsset>()//[PHAsset]()
    private var lastTimeNewItemsAppended: Date?
    
    
    // MARK: - Init
    
    init() {
        photoSyncService.delegate = self
        videoSyncService.delegate = self
        BackgroundTaskService.shared.expirationDelegates.add(self)
        debugLog("SyncServiceManager initialized")
    }
    
    deinit {
        reachabilityService.delegates.remove(self)
        NotificationCenter.default.removeObserver(self)
        debugLog("SyncServiceManager deinitialized")
    }
    
    
    // MARK: - Public
    func update(syncSettings: AutoSyncSettings) {
        debugLog("SyncServiceManager updateSyncSettings")
        
        subscribeForNotifications()
        
        settings = syncSettings
        
        checkReachabilityAndSettings(reachabilityChanged: false, newItems: false)
    }
    
    func setupAutosync() {
        debugLog("SyncServiceManager setupAutosync")
        
        subscribeForNotifications()
        
        lastAutoSyncTime = Date().timeIntervalSince1970
    }
    
    func update() {
        debugLog("SyncServiceManager update")
        
        lastAutoSyncTime = Date().timeIntervalSince1970
        if !hasExecutingSync, !hasPrepairingSync {
            checkReachabilityAndSettings(reachabilityChanged: false, newItems: false)
        }
    }
    
    func updateImmediately() {
        debugLog("SyncServiceManager updateImmediately")
        
        lastAutoSyncTime = Date().timeIntervalSince1970
        checkReachabilityAndSettings(reachabilityChanged: false, newItems: false)
    }
    
    func updateInBackground() {
        debugLog("SyncServiceManager updateInBackground")
        sendNetmeraEvent()
        let time = Date().timeIntervalSince1970
        if time - lastAutoSyncTime > timeIntervalBetweenSyncsInBackground {
            BackgroundTaskService.shared.beginBackgroundTask()
            lastAutoSyncTime = time
            debugLog("Sync should start in background")
            checkReachabilityAndSettings(reachabilityChanged: false, newItems: false)
        }
    }
    
    func backgroundTaskSync(handler: @escaping BoolHandler) {
        self.backgroundSyncHandler = handler
        debugLog("AUTOSYNC: backgroundTaskSync handlesr setuped")
        checkReachabilityAndSettings(reachabilityChanged: false, newItems: false)
    }
    
    func stopSync() {
        debugLog("SyncServiceManager stopSync")
        
        WidgetService.shared.notifyWidgetAbout(status: .stoped)
        stop(photo: true, video: true)
    }
    
    
    // MARK: - Private
    
    
    private func checkReachabilityAndSettings(reachabilityChanged: Bool, newItems: Bool) {
        guard coreDataStack.isReady else {
            printLog("AUTOSYNC: coreDataStack isn't ready")
            backgroundSyncHandler?(false)
            return
        }
        
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            debugLog("AUTOSYNC: reachability start")
            self.timeIntervalBetweenSyncsInBackground = NumericConstants.timeIntervalBetweenAutoSyncInBackground
            
            guard self.settings.isAutoSyncEnabled else {
                debugLog("AUTOSYNC: autosync disabled")
                self.backgroundSyncHandler?(false)
                self.stopSync()
                CardsManager.default.startOperationWith(type: .autoUploadIsOff, allOperations: nil, completedOperations: nil)
                return
            }
            
            CardsManager.default.stopOperationWith(type: .autoUploadIsOff)
            
            let photoOption = self.settings.photoSetting.option
            let videoOption = self.settings.videoSetting.option
            
            if self.reachabilityService.isReachable {
                let photoEnabled = (self.reachabilityService.isReachableViaWiFi && photoOption != .never) ||
                    (self.reachabilityService.isReachableViaWWAN && photoOption == .wifiAndCellular)
                
                let videoEnabled = (self.reachabilityService.isReachableViaWiFi && videoOption != .never) ||
                    (self.reachabilityService.isReachableViaWWAN && videoOption == .wifiAndCellular)
                
                let photoServiceWaitingForWiFi = self.reachabilityService.isReachableViaWWAN && photoOption == .wifiOnly
                //                itemsSortedToUpload if 0 then no
                let videoServiceWaitingForWiFi = self.reachabilityService.isReachableViaWWAN && videoOption == .wifiOnly
                
                let shoudStopPhotoSync = !photoEnabled && !photoServiceWaitingForWiFi
                let shouldStopVideoSync = !videoEnabled && !videoServiceWaitingForWiFi
                
                self.stop(photo: shoudStopPhotoSync, video: shouldStopVideoSync)
                self.waitForWifi(photo: photoServiceWaitingForWiFi, video: videoServiceWaitingForWiFi)
                debugLog("AUTOSYNC: is reachable and AS going to start")
                self.start(photo: photoEnabled, video: videoEnabled, newItems: newItems)
            } else {
                let photoServiceWaitingForWiFi = photoOption != .never
                let videoServiceWaitingForWiFi = videoOption != .never
                debugLog("AUTOSYNC: waiting for wifi")
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
                ///we need to stop video sync every time
                ///to prevent autosync if it was interrupted in the background
                ///and if network was changed from wifi to cellular
//                videoSyncService.stop()
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
    
    private func restart() {
        stop(photo: true, video: true)
        checkReachabilityAndSettings(reachabilityChanged: false, newItems: false)
    }
    
    private var isSubscribeForNotifications = false
    
    private func sendNetmeraEvent() {
        let event = NetmeraEvents.Actions.BackgroundSync(syncType: .locationChange)
        AnalyticsService.sendNetmeraEvent(event: event)
    }
}


// MARK: - Notifications
extension SyncServiceManager {
    private func subscribeForNotifications() {
        
        guard LocalMediaStorage.default.photoLibraryIsAvailible(), !isSubscribeForNotifications else {
            return
        }
        isSubscribeForNotifications = true
        reachabilityService.delegates.add(self)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(onPhotoLibraryDidChange(notification:)),
                                       name: .notificationPhotoLibraryDidChange,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(onAutoSyncStatusDidChange),
                                       name: .autoSyncStatusDidChange,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(onLocalFilesHaveBeenLoaded),
                                       name: .allLocalMediaItemsHaveBeenLoaded,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(onLocalAlbumStatusDidChange),
                                       name: .localAlbumStatusDidChange,
                                       object: nil)
    }
    
    @objc private func onPhotoLibraryDidChange(notification: Notification) {
        if let phChanges = notification.userInfo {
            if let addedAssets = phChanges[PhotoLibraryChangeType.added] as? [PHAsset] {
                newItemsToAppend.append(addedAssets)
            } else if let removedAssets = phChanges[PhotoLibraryChangeType.removed] as? [PHAsset] {
                for asset in removedAssets {
                    newItemsToAppend.remove(where: {$0.localIdentifier == asset.localIdentifier})
                }
                if newItemsToAppend.isEmpty {
                    checkReachabilityAndSettings(reachabilityChanged: false, newItems: false)
                }
            }
            lastTimeNewItemsAppended = Date()
            checkItemsToAppend()
        }
    }
    
    private func checkItemsToAppend() {
        guard let lastChangeTime = lastTimeNewItemsAppended, !newItemsToAppend.isEmpty else {
            return
        }
        
        let timeInterval = Date().timeIntervalSince(lastChangeTime)
        
        if timeInterval > NumericConstants.intervalInSecondsBetweenAutoSyncItemsAppending {
            checkReachabilityAndSettings(reachabilityChanged: false, newItems: true)
            newItemsToAppend.removeAll()
        } else {
            let intervalToSyncAfter = Int(NumericConstants.intervalInSecondsBetweenAutoSyncItemsAppending - timeInterval)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(intervalToSyncAfter)) {
                self.checkItemsToAppend()
            }
        }
    }
    
    @objc private func onLocalFilesHaveBeenLoaded() {
        self.checkReachabilityAndSettings(reachabilityChanged: false, newItems: false)
    }
    
    @objc private func onLocalAlbumStatusDidChange() {
        restart()
    }
    
    @objc private func onAutoSyncStatusDidChange() {
        
        if hasExecutingSync, self.reachabilityService.isReachable {
            WidgetService.shared.notifyWidgetAbout(status: .executing)

            CardsManager.default.stopOperationWith(type: .waitingForWiFi)
            CardsManager.default.stopOperationWith(type: .prepareToAutoSync)
            return
        }
        
        CardsManager.default.stopOperationWith(type: .sync)
        WidgetService.shared.notifyWidgetAbout(status: .stoped)
        
        if hasPrepairingSync {
//            CardsManager.default.startOperationWith(type: .prepareToAutoSync, allOperations: nil, completedOperations: nil)
            CardsManager.default.stopOperationWith(type: .sync)
            CardsManager.default.stopOperationWith(type: .waitingForWiFi)
            return
        }
        
        CardsManager.default.stopOperationWith(type: .prepareToAutoSync)
        
        FreeAppSpace.session.checkFreeUpSpaceAfterAutoSync()
        
        if isSyncFinished {
            backgroundSyncHandler?(true)
        }
        
        if settings.isAutoSyncEnabled, hasWaitingForWiFiSync, CacheManager.shared.isCacheActualized {
            CardsManager.default.startOperationWith(type: .waitingForWiFi)
            return
        }
    }
}


// MARK: - ItemSyncServiceDelegate

extension SyncServiceManager: ItemSyncServiceDelegate {
    func didReceiveOutOfSpaceError() {
        stopSync()
        if ApplicationStateHelper.shared.isBackground {
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
        RouterVC().showFullQuotaPopUp()
    }
}

//MARK: - ReachabilityServiceDelegate

extension SyncServiceManager: ReachabilityServiceDelegate {
    func reachabilityDidChanged(_ service: ReachabilityService) {
        debugPrint("AUTOSYNC: is" + (service.isReachable ? "reachable" : "unreachable"))

        self.checkReachabilityAndSettings(reachabilityChanged: true, newItems: false)
    }
}


extension SyncServiceManager: BackgroundTaskServiceDelegate {
    func backgroundTaskWillExpire() {
        stopSync()
    }
}
