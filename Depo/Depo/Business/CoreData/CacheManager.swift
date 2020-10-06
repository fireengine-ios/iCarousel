//
//  CacheManager.swift
//  Depo
//
//  Created by Aleksandr on 8/10/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//


/*
 //
 //adding files TO DB // managing cache
 //
 */

protocol CacheManagerDelegate: class {
    func didCompleteCacheActualization()
}

final class CacheManager {
    
    static let shared = CacheManager()
    
    private lazy var coreDataStack: CoreDataStack = factory.resolve()
    private lazy var logoutCleaner: LogoutDBCleaner = factory.resolve()
    
    private static let pageSize: Int = 500
    private let photoVideoService = PhotoAndVideoService(requestSize: CacheManager.pageSize,
                                                         type: .imageAndVideo)

    private let reachabilityService = ReachabilityService.shared
    private(set) var processingRemoteItems = false
    private(set) var processingLocalItems = false
    private(set) var isProcessing = false
    private(set) var isCacheActualized: Bool = false {
        didSet {
            WidgetService.shared.isPreperationFinished = isCacheActualized
        }
    }
    
    let delegates = MulticastDelegate<CacheManagerDelegate>()
    
    private let userDefaultsVars = UserDefaultsVars()
    
    private var internetConnectionIsBackCallback: VoidHandler?
    
    //MARK: -
    
    deinit {
        reachabilityService.delegates.remove(self)
    }
    
    func actualizeCache() {
        debugLog("CacheManager calling actualizeCache")
        
        guard coreDataStack.isReady else {
            debugLog("CacheManager coreData not ready")
            scheduleActualization()
            return
        }
        
        guard !isProcessing else {
            debugLog("CacheManager Still processing remotes...")
            return
        }
        
        debugLog("CacheManager starting actualizeCache")
        
        isCacheActualized = false
        isProcessing = true

        self.startProccessingLocalAlbums { [weak self] in
            debugLog("CacheManager startProccessingLocalAlbums")
            guard let self = self else {
                return
            }
            
            debugLog("CacheManager albums are processed")
            
            MediaItemOperationsService.shared.removeZeroBytesLocalItems { [weak self] _ in
                debugLog("CacheManager zero bytes items removed")
                MediaItemOperationsService.shared.isNoRemotesInDB { [weak self] isNoRemotes in
                    debugLog("CacheManager isNoRemotes \(isNoRemotes)")
                    guard let self = self else {
                        return
                    }
                    
                    if isNoRemotes || self.userDefaultsVars.currentRemotesPage > 0 {
                        self.showPreparationCardAfterDelay()
                        self.startAppendingAllRemotes(completion: { [weak self] in
                            debugLog("CacheManager no remotes, appended all remotes")
                            guard let self = self, !self.processingRemoteItems else {
                                return
                            }
                            
                            self.userDefaultsVars.currentRemotesPage = 0
                            self.startProcessingAllLocals(completion: { [weak self] in
                                self?.actualizeUnsavedFileSyncStatus() { [weak self] in
                                    guard let self = self, !self.processingLocalItems else {
                                        return
                                    }
                                    debugLog("CacheManager no remotes, all locals processed")
                                    //FIXME: need handling if we logouted and locals still in progress
                                    
                                    
                                    self.isProcessing = false
                                    self.isCacheActualized = true
                                    debugLog("CacheManager cache is actualized")
                                    self.updatePreparation(isBegun: false)
                                    SyncServiceManager.shared.updateImmediately()
                                    
                                    let mediaService = MediaItemOperationsService.shared
                                    mediaService.allUnsyncedLocalIds { unsyncedLocalIds in
                                        mediaService.allLocalIds(subtractingIds: unsyncedLocalIds) { syncedLocalIds in
                                            SharedGroupCoreDataStack.shared.actualizeWith(synced: syncedLocalIds, unsynced: unsyncedLocalIds)
                                        }
                                    }
                                    
                                    self.delegates.invoke { $0.didCompleteCacheActualization() }
                                }
                            })
                        })
                    } else {
                        guard !self.processingLocalItems else {/// these checks are made just to double check, there is already inProcessLocalFiles flag in MediaItemsOperationService processLocalGallery method
                            debugLog("CacheManager there are remotes, but locals already being processed")
                            return
                        }
                        self.showPreparationCardAfterDelay()
                        self.startProcessingAllLocals(completion: { [weak self] in
                            self?.actualizeUnsavedFileSyncStatus() { [weak self] in
                                guard let self = self, !self.processingRemoteItems else {
                                    return
                                }
                                debugLog("CacheManager there are remotes, all local processed")
                                self.isProcessing = false
                                self.isCacheActualized = true
                                debugLog("CacheManager cache is actualized")
                                self.updatePreparation(isBegun: false)
                                SyncServiceManager.shared.updateImmediately()
                                
                                let mediaService = MediaItemOperationsService.shared
                                mediaService.allUnsyncedLocalIds { unsyncedLocalIds in
                                    mediaService.allLocalIds(subtractingIds: unsyncedLocalIds) { syncedLocalIds in
                                        SharedGroupCoreDataStack.shared.actualizeWith(synced: syncedLocalIds, unsynced: unsyncedLocalIds)
                                    }
                                }
                                
                                self.delegates.invoke { $0.didCompleteCacheActualization() }
                            }
                        })
                    }
                }
            }
        }
    }
    
    private func updatePreparation(isBegun: Bool) {
        if isBegun {
            CardsManager.default.startOperationWith(type: .prepareQuickScroll)
        } else {
            CardsManager.default.stopOperationWith(type: .prepareQuickScroll)
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = isBegun
        }
    }
    
    private func scheduleActualization() {
        coreDataStack.delegates.add(self)
    }
    
    private func showPreparationCardAfterDelay() {
        ///prevent blinking
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            if self.isProcessing {
                self.updatePreparation(isBegun: true)
            }
        })
    }
    
    private func startAppendingAllRemotes(completion: @escaping VoidHandler) {
        /// we save remotes everytime, no metter if acces to PH libriary denied
            photoVideoService.currentPage = userDefaultsVars.currentRemotesPage
            guard !self.processingRemoteItems else {
                return
            }
        
            debugLog("actualizeCache processing remote items")
        
            self.processingRemoteItems = true
            self.addNextRemoteItemsPage { [weak self] in
                self?.processingRemoteItems = false
                completion()
            }
    }
    
    private func addNextRemoteItemsPage(completion: @escaping VoidHandler) {
        photoVideoService.nextItems(fileType: .imageAndVideo, sortBy: .imageDate, sortOrder: .desc, success: { [weak self] remoteItems in
            guard let self = self else {
                return
            }
            
            guard self.processingRemoteItems else {
                debugLog("actualizeCache: not processing")
                return
            }
            
            guard !remoteItems.isEmpty else {
                debugLog("actualizeCache: got empty page")
                self.photoVideoService.currentPage = 0
                completion()
                return
            }
            
            MediaItemOperationsService.shared.appendRemoteMediaItems(remoteItems: remoteItems) { [weak self] in
                guard let self = self else {
                    completion()
                    return
                }
                
                //FIXME: When BackEnd would fix duplication problem we should remove else part
                let page = self.photoVideoService.currentPage
                self.userDefaultsVars.currentRemotesPage = page
                debugLog("actualizeCache: save current page \(page)")
                
                self.addNextRemoteItemsPage(completion: completion)
            }
            //FIXME: When BackEnd would fix duplication problem we should uncomment this
//            if remoteItems.count >= CacheManager.pageSize {
//                self.addNextRemoteItemsPage(completion: completion)
//            }
            
        }, fail: { [weak self] in
            guard let self = self else {
                completion()
                return
            }
            guard self.processingRemoteItems else {
                return
            }
            
            self.handleLostConnection(completion: completion)
        })
    }
    
    private func handleLostConnection(completion: @escaping VoidHandler) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            //delay need for case when we received a response before changing the status of ReachabilityService
            ///start subscribing
            self?.checkInternetConnection { [weak self] in
                self?.addNextRemoteItemsPage(completion: completion)
            }
        }
    }
    
    private func checkInternetConnection(internetConnectionBackCallback: @escaping VoidHandler) {
        guard reachabilityService.isReachable else {
            reachabilityService.delegates.add(self)
            internetConnectionIsBackCallback = { [weak self] in
                self?.internetConnectionIsBackCallback = nil
                self?.checkInternetConnection(internetConnectionBackCallback: internetConnectionBackCallback)
            }
            return
        }
        internetConnectionBackCallback()
    }
    
    private func startProccessingLocalAlbums(completion: @escaping VoidHandler) {
        MediaItemsAlbumOperationService.shared.processLocalMediaItemAlbums(completion: completion)
    }
    
    private func startProcessingAllLocals(completion: @escaping VoidHandler) {
        guard !self.processingLocalItems else {
            return
        }
        debugLog("actualizeCache processing local items")
        
        processingLocalItems = true
        MediaItemOperationsService.shared.processLocalMediaItems { [weak self] in
            self?.processingLocalItems = false
            completion()
        }
    }
    
    func stopRemotesActualizeCache() {
        debugLog("CacheManager stop remotes actualization")
        
        if processingRemoteItems {
            processingRemoteItems = false
            //        processingLocalItems = false//still need to test what would ahppen in parallel downlaod
            isProcessing = false
            photoVideoService.stopAllOperations() //Dont know if it actualy affects opration by cancell all
            ///unsubscribe
        }
        
        isCacheActualized = false
        reachabilityService.delegates.remove(self)
        internetConnectionIsBackCallback = nil
    }
    
    func dropAllRemotes(completion: VoidHandler?) {
        debugLog("dropAllRemotes")
        
        userDefaultsVars.currentRemotesPage = 0
        processingRemoteItems = false
        isCacheActualized = false
        
        logoutCleaner
            .onCompletion(completion: completion)
            .start()
    }
    
    func logout(completion: VoidHandler?) {
        delegates.removeAll()
        stopRemotesActualizeCache()
        dropAllRemotes(completion: completion)
    }
    
    //TODO: move method of QS DB update here.

}

//MARK: - Sync Status Actualization
extension CacheManager {
    ///Since we backgeound tasks can expire before we save latest changes to DB
    ///In order to prevent duplication of unsaved file, we call it on each actualization
    private func actualizeUnsavedFileSyncStatus(completion: @escaping VoidHandler) {
        //TODO: during actualisation task, think about the best way to call it for regular launch
        debugLog("CacheManager checkLatestUnsavedFile")
        guard let latestUnsavedUUID = userDefaultsVars.lastUnsavedFileUUID else {
            debugLog("CacheManager no unsaved items found")
            completion()
            return
        }
        
        let remoteFileService = FileService.shared
        remoteFileService.details(uuids: [latestUnsavedUUID], success: { [weak self] items in
            guard let remoteItem = items.first else {
                debugLog("CacheManager no item with this UUID \(items.count)")
                completion()
                return
            }
            debugLog("CacheManager TEST: got detail info for last UNSAVED to DB \(remoteItem.uuid) AND name \(remoteItem.name)")
            
            let trimmedLocalID = remoteItem.getTrimmedLocalID()
            
            MediaItemOperationsService.shared.mediaItemByLocalID(trimmedLocalIDS: [trimmedLocalID]) { [weak self] localItems in
                guard let firstLocal = localItems.first else {
                    debugLog("CacheManager ERROR: Failed to find related locals with this  ID")
                    completion()
                    return
                }
                debugLog("CacheManager found related local to unsaved remote")
                
                let localWrapData = WrapData(mediaItem: firstLocal)
                localWrapData.syncStatus = .synced
                localWrapData.setSyncStatusesAsSyncedForCurrentUser()
                
                MediaItemOperationsService.shared.updateLocalItemSyncStatus(item: localWrapData, newRemote: remoteItem) { [weak self] in
                    debugLog("CacheManager TEST: SYNC stasus updated last unsaved UPDATED uuid \(self?.userDefaultsVars.lastUnsavedFileUUID) AND name \(remoteItem.name)")
                    self?.userDefaultsVars.lastUnsavedFileUUID = nil
                    completion()
                }
            }
            }, fail: { error in
                debugLog("CacheManager ERROR: faild to get item details \(error.description)")
                completion()
        })
    }
}

//MARK: - ReachabilityServiceDelegate
extension CacheManager: ReachabilityServiceDelegate {
    func reachabilityDidChanged(_ service: ReachabilityService) {
        if service.isReachable {
            internetConnectionIsBackCallback?()
        }
    }
}


extension CacheManager: CoreDataStackDelegate {
    func onCoreDataStackSetupCompleted() {
        debugLog("CacheManager scheduled actualization start")
        coreDataStack.delegates.remove(self)
        actualizeCache()
    }
}
