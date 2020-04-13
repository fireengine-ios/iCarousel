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
    
    private static let pageSize: Int = 500
    private let photoVideoService = PhotoAndVideoService(requestSize: CacheManager.pageSize,
                                                         type: .imageAndVideo)

    private let reachabilityService = ReachabilityService.shared
    private(set) var processingRemoteItems = false
    private(set) var processingLocalItems = false
    private(set) var isProcessing = false
    private(set) var isCacheActualized = false
    
    let delegates = MulticastDelegate<CacheManagerDelegate>()
    
    private let userDefaultsVars = UserDefaultsVars()
    
    private var internetConnectionIsBackCallback: VoidHandler?
    
    //MARK: -
    
    deinit {
        reachabilityService.delegates.remove(self)
    }
    
    func actualizeCache() {
        debugLog("calling actualizeCache")
        
        guard coreDataStack.isReady else {
            debugLog("CacheManager coreData nor ready")
            scheduleActualization()
            return
        }
        
        debugLog("starting actualizeCache")
        
        isCacheActualized = false
        isProcessing = true

        self.startProccessingLocalAlbums { [weak self] in
            debugLog("CacheManager startProccessingLocalAlbums")
            guard let self = self else {
                return
            }
            
            debugLog("actualizeCache albums are processed")
            
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
                                guard let self = self, !self.processingLocalItems else {
                                    return
                                }
                                debugLog("CacheManager no remotes, all locals processed")
                                //FIXME: need handling if we logouted and locals still in progress
                                self.isProcessing = false
                                self.isCacheActualized = true
                                debugLog("cache is actualized")
                                self.updatePreparation(isBegun: false)
                                self.delegates.invoke { $0.didCompleteCacheActualization() }
                            })
                        })
                    } else {
                        guard !self.processingLocalItems else {/// these checks are made just to double check, there is already inProcessLocalFiles flag in MediaItemsOperationService processLocalGallery method
                            debugLog("CacheManager there are remotes, but locals already being processed")
                            return
                        }
                        self.showPreparationCardAfterDelay()
                        self.startProcessingAllLocals(completion: { [weak self] in
                            debugLog("CacheManager there are remotes, all local processed")
                            self?.isProcessing = false
                            self?.isCacheActualized = true
                            debugLog("cache is actualized")
                            self?.updatePreparation(isBegun: false)
                            self?.delegates.invoke { $0.didCompleteCacheActualization() }
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
                return
            }
            
            MediaItemOperationsService.shared.appendRemoteMediaItems(remoteItems: remoteItems) { [weak self] in
                guard let self = self else {
                    completion()
                    return
                }
                
                if remoteItems.count < CacheManager.pageSize {
                    self.photoVideoService.currentPage = 0
                    completion()///means all files are downloaded
                } else {
                    //FIXME: When BackEnd would fix duplication problem we should remove else part
                    self.userDefaultsVars.currentRemotesPage = self.photoVideoService.currentPage
                    self.addNextRemoteItemsPage(completion: completion)
                }
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
        processingRemoteItems = false
//        processingLocalItems = false//still need to test what would ahppen in parallel downlaod
//        isProcessing = false
        isCacheActualized = false
        photoVideoService.stopAllOperations() //Dont know if it actualy affects opration by cancell all
        ///unsubscribe
        reachabilityService.delegates.remove(self)
        internetConnectionIsBackCallback = nil
    }
    
    func dropAllRemotes(completion: VoidHandler?) {
        debugLog("dropAllRemotes")
        
        userDefaultsVars.currentRemotesPage = 0
        processingRemoteItems = false
        isCacheActualized = false
        MediaItemOperationsService.shared.deleteRemoteEntities { _ in
            debugLog("dropAllRemotes success")
            completion?()
        }
    }
    
    func logout(completion: VoidHandler?) {
        delegates.removeAll()
        stopRemotesActualizeCache()
        dropAllRemotes(completion: completion)
    }
    
    //TODO: move method of QS DB update here.

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
        debugLog("CacheManager scheduled actulasation start")
        coreDataStack.delegates.remove(self)
        actualizeCache()
    }
}
