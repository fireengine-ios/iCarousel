//
//  SettingsSettingsInteractor.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

final class SettingsInteractor: SettingsInteractorInput {

    weak var output: SettingsInteractorOutput!
    
    private let authService = AuthenticationService()

    private lazy var storageVars: StorageVars = factory.resolve()

    private(set) var userStorageInfo: SettingsStorageUsageResponseItem?

    func onLogout() {
        output.asyncOperationStarted()
        authService.serverLogout(complition: { [weak self] success in
            self?.authService.logout { [weak self] in
                self?.output.asyncOperationStoped()
                self?.output.goToLoginScreen()
            }
        })
    }
    
    func getUserInfo() {
        let userAccountUuid = SingletonStorage.shared.accountInfo?.uuid ?? ""
        let organizationUUID = SingletonStorage.shared.accountInfo?.parentAccountInfo.uuid ?? ""
        SingletonStorage.shared.getStorageUsageInfo(projectId: organizationUUID, userAccountId: userAccountUuid, success: { [weak self] info in
            self?.userStorageInfo = info
            self?.output.updateStorageUsageDataInfo()
            self?.output.asyncOperationStoped()
        }, fail: { [weak self] errorResponse in
            self?.output.asyncOperationStoped()
            self?.output.didFailToRetrieveUsageData(error: errorResponse)
        })
    }

    func checkConnectedToNetwork() {
        let reachability = ReachabilityService.shared
        let isWiFi = reachability.isReachable
        isWiFi ? onLogout() : output.connectToNetworkFailed()
    }
}
