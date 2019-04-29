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
    
    private static let pageSize: Int = 100
    private let photoVideoService = PhotoAndVideoService(requestSize: CacheManager.pageSize,
                                                         type: .imageAndVideo)
    private lazy var reachabilityService = APIReachabilityService()
    private(set) var processingRemoteItems = false
    private(set) var processingLocalItems = false
    private(set) var isProcessing = false
    private(set) var isCacheActualized = false
    
    let delegates = MulticastDelegate<CacheManagerDelegate>()
    
    private let userDefaultsVars = UserDefaultsVars()
    
    private var internetConnectionIsBackCallback: VoidHandler?
    
    deinit {
        reachabilityService.stopNotifier()
        NotificationCenter.default.removeObserver(self)
    }
    
    func actualizeCache(completion: VoidHandler?) {
        if !isProcessing || processingLocalItems || processingRemoteItems {
            CardsManager.default.startOperationWith(type: .preparePhotosQuickScroll)
        }
        
        isCacheActualized = false
        isProcessing = true

        MediaItemOperationsService.shared.isNoRemotesInDB { [weak self] isNoRemotes in
            guard let `self` = self else {
                completion?()
                return
            }
            if isNoRemotes || self.userDefaultsVars.currentRemotesPage > 0 {
                self.startAppendingAllRemotes(completion: { [weak self] in
                    self?.userDefaultsVars.currentRemotesPage = 0
                    self?.startAppendingAllLocals(completion: { [weak self] in
                        guard let `self` = self,
                            !self.processingLocalItems else {
                            completion?()
                            return
                        }
                        self.isProcessing = false
                        self.isCacheActualized = true
                        CardsManager.default.stopOperationWithType(type: .preparePhotosQuickScroll)
                        self.delegates.invoke { $0.didCompleteCacheActualization() }
                        completion?()
                    })
                })
            } else {
                guard !self.processingLocalItems else {/// these checks are made just to double check, there is already inProcessAppendingLocalFiles flag in MediaItemsOperationService insertFromGallery method
                    completion?()
                    return
                }
                self.startAppendingAllLocals(completion: { [weak self] in
                    self?.isProcessing = false
                    self?.isCacheActualized = true
                    CardsManager.default.stopOperationWithType(type: .preparePhotosQuickScroll)
                    self?.delegates.invoke { $0.didCompleteCacheActualization() }
                    completion?()
                })
            }
        }
    }
    
    private func startAppendingAllRemotes(completion: @escaping VoidHandler) {
        /// we save remotes everytime, no metter if acces to PH libriary denied
            photoVideoService.currentPage = userDefaultsVars.currentRemotesPage
            guard !self.processingRemoteItems else {
                return
            }
        
            self.processingRemoteItems = true
            self.addNextRemoteItemsPage { [weak self] in
                self?.processingRemoteItems = false
                completion()
            }
    }
    
    private func addNextRemoteItemsPage(completion: @escaping VoidHandler) {
        photoVideoService.nextItems(fileType: .imageAndVideo, sortBy: .imageDate, sortOrder: .desc, success: { [weak self] remoteItems in
            guard let `self` = self else {
                return
            }
            guard self.processingRemoteItems else {
                return
            }
            self.userDefaultsVars.currentRemotesPage = self.photoVideoService.currentPage
            
            MediaItemOperationsService.shared.appendRemoteMediaItems(remoteItems: remoteItems) { [weak self] in
                if remoteItems.count < CacheManager.pageSize {
                    self?.photoVideoService.currentPage = 0
                    completion()///means all files are downloaded
                }
            }
            if remoteItems.count >= CacheManager.pageSize {
                self.addNextRemoteItemsPage(completion: completion)
            }
            
        }) { [weak self] in
            guard let `self` = self else {
                completion()
                return
            }
            guard self.processingRemoteItems else {
                return
            }
            ///start subscribing
            self.checkInternetConnection { [weak self] in
                self?.addNextRemoteItemsPage(completion: completion)
            }
        }
    }
    
    private func checkInternetConnection(iternetConnectionBackCallback: @escaping VoidHandler) {
        guard reachabilityService.connection == .reachable else {
            NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityDidChanged), name: .apiReachabilityDidChange, object: nil)
            reachabilityService.startNotifier()
            internetConnectionIsBackCallback = { [weak self] in
                self?.internetConnectionIsBackCallback = nil
                self?.checkInternetConnection(iternetConnectionBackCallback: iternetConnectionBackCallback)
            }
            return
        }
        iternetConnectionBackCallback()
    }
    
    @objc private func reachabilityDidChanged() {
        guard reachabilityService.connection == .reachable else {
            return
        }
        reachabilityService.stopNotifier()
        NotificationCenter.default.removeObserver(self)
        internetConnectionIsBackCallback?()
    }
    
    private func startAppendingAllLocals(completion: @escaping VoidHandler) {
        guard !self.processingLocalItems else {
            return
        }
        
        processingLocalItems = true
        MediaItemOperationsService.shared.appendLocalMediaItems { [weak self] in
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
        reachabilityService.stopNotifier()
        NotificationCenter.default.removeObserver(self)
        internetConnectionIsBackCallback = nil
    }
    
    func dropAllRemotes(completion: VoidHandler?) {
        userDefaultsVars.currentRemotesPage = 0
        processingRemoteItems = false
        isCacheActualized = false
        MediaItemOperationsService.shared.deleteRemoteEntities { _ in
            completion?()
        }
    }
    
    //TODO: move method of QS DB update here.

}
