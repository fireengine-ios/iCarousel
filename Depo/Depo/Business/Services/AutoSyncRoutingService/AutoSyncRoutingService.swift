//
//  AutoSyncRoutingService.swift
//  Depo
//
//  Created by Harbros 3 on 2/25/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class AutoSyncRoutingService {
    typealias AutoSyncHandler  = (Bool) -> ()
    
    private lazy var accountService = AccountService()
    private lazy var dataStorage = AutoSyncDataStorage()
    
    private lazy var router = RouterVC()
    
    private var successHandler: AutoSyncHandler?
    private var errorHandler: FailResponse?

    // MARK: Utility Methods(public)
    func checkNeededOpenAutoSync(success: @escaping AutoSyncHandler, error: @escaping FailResponse) {
        successHandler = success
        errorHandler = error
        
        getFeatures()
    }
    
    // MARK: Utility Methods(private)
    private func getFeatures() {
        accountService.getFeatures { [weak self] (response) in
            switch response {
            case .success(let result):
                if result.isAutoSyncDisabled == true {
                    self?.disableAutoSync()
                    self?.didOpenHome()
                    self?.successHandler?(false)
                } else {
                    guard let successHandler = self?.successHandler else {
                        assertionFailure()
                        return
                    }
                    
                    successHandler(true)
                }
            case .failed(_):
                guard let successHandler = self?.successHandler else {
                    assertionFailure()
                    return
                }
                
                successHandler(true)
            }
        }
    }
    
    private func didOpenHome() {
        let tabBarController = router.tabBarScreen
        router.setNavigationController(controller: tabBarController)
    }
    
    private func disableAutoSync() {
        let settings = dataStorage.settings
        settings.disableAutoSync()
        dataStorage.save(autoSyncSettings: settings, fromSetting: false)
        SyncServiceManager.shared.update(syncSettings: settings)
    }
    
}
