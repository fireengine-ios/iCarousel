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

import Reachability

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
    
    private var currentRemotesPage: Int {
        get {
            return UserDefaults.standard.integer(forKey: Keys.lastRemotesPageSaved)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.lastRemotesPageSaved)
        }
    }
    
    deinit {
        reachabilityService.stopNotifier()
        NotificationCenter.default.removeObserver(self)
    }
    
    func actualizeCache(completion: VoidHandler?) {
        if !isProcessing {
            CardsManager.default.startOperationWith(type: .preparePhotosQuickScroll)
        }
        
        isCacheActualized = false
        isProcessing = true

        MediaItemOperationsService.shared.isNoRemotesInDB { [weak self] isNoRemotes in
            guard let `self` = self else {
                completion?()
                return
            }
            debugPrint("!!!! \(self.currentRemotesPage)")
            if isNoRemotes || self.currentRemotesPage > 0 {
                self.startAppendingAllRemotes(completion: { [weak self] in
                    self?.currentRemotesPage = 0
                    self?.startAppendingAllLocals(completion: {
                        self?.isProcessing = false
                        self?.isCacheActualized = true
                        CardsManager.default.stopOperationWithType(type: .preparePhotosQuickScroll)
                        self?.delegates.invoke { $0.didCompleteCacheActualization() }
                        completion?()
                    })
                })
            } else {
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
            photoVideoService.currentPage = currentRemotesPage
            guard !self.processingRemoteItems else {
                return
            }
        
            self.processingRemoteItems = true
            self.addNextRemoteItemsPage { [weak self] in
                self?.processingRemoteItems = false
//                self?.remotePageAdded?()
                completion()
            }
    }
    
    private func addNextRemoteItemsPage(completion: @escaping VoidHandler) {
        photoVideoService.nextItems(fileType: .imageAndVideo, sortBy: .imageDate, sortOrder: .desc, success: { [weak self] remoteItems in
            guard let `self` = self else {
                return
            }
            self.currentRemotesPage = self.photoVideoService.currentPage
            MediaItemOperationsService.shared.appendRemoteMediaItems(remoteItems: remoteItems) { [weak self] in
                //                self?.remotePageAdded?()
                if remoteItems.count < CacheManager.pageSize {
                    self?.photoVideoService.currentPage = 0
                    completion()
                }
            }
            if remoteItems.count >= CacheManager.pageSize {
                self.addNextRemoteItemsPage(completion: completion)
            }
            
        }) { [weak self] in
            guard let `self` = self else { //, let reachabilityService = self.reachabilityService
                completion()
                return
            }
            //should I check here if reachability?
            ///start subscribing
            ///option 3
//            let requestService = APIReachabilityRequestService()
//
            
            ///option 2
            NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityDidChanged), name: .apiReachabilityDidChange, object: nil)
            self.reachabilityService.startNotifier()
            ///option 1
//            switch reachabilityService.connection {
//            case .cellular, .wifi:
//                self.addNextRemoteItemsPage(completion: completion)
//            case .none:
            
//                try? self.reachabilityService?.startNotifier()
//                self.reachabilityService?.whenReachable = { [weak self] reachability in
//                    self?.reachabilityService?.stopNotifier()
//                    self?.addNextRemoteItemsPage(completion: completion)
//                }
//            }
            
            
            
//            completion()///// create some kind of system where we wait till the internet is back and send request again
        }
    }
    
    @objc private func reachabilityDidChanged() {
        guard reachabilityService.connection == .reachable else {
            return
        }
        reachabilityService.stopNotifier()
        NotificationCenter.default.removeObserver(self)
        isProcessing = false
        processingRemoteItems = false
        
        actualizeCache(completion: nil)
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
    
    func dropAllRemotes(completion: VoidHandler?) {
        currentRemotesPage = 0
        MediaItemOperationsService.shared.deleteRemoteEntities { _ in
            completion?()
        }
    }
    
    
    //TODO: move method of QS DB update here.

}
