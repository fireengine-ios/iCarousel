//
//  ImportFromInstagramInteractor.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/22/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

class ImportFromInstagramInteractor {
    weak var instOutput: ImportFromInstagramInteractorOutput?
    private let instService = InstagramService()
    private let accountService = AccountService()
    private let analyticsService: AnalyticsService = factory.resolve()
}

extension ImportFromInstagramInteractor: ImportFromInstagramInteractorInput {
    
    func getAllStatuses() {
        let failureHandler: FailResponse = { [weak self] errorResponse in
            if let output = self?.instOutput {
                output.instaPickFailure(errorMessage: errorResponse.description)
                output.connectionFailure(errorMessage: errorResponse.description)
                output.syncStatusFailure(errorMessage: errorResponse.description)
            }
        }
        
        instService.socialStatus(success: { [weak self] response in
            guard let response = response as? SocialStatusResponse,
                let isConnected = response.instagram
            else {
                return
            }
            
            DispatchQueue.toMain {
                self?.instOutput?.connectionSuccess(isConnected: isConnected, username: response.instagramUsername)
            }
            
            if isConnected {
                self?.getSyncStatus()
                self?.getInstaPickStatus()
            } else {
                DispatchQueue.toMain {
                    if let output = self?.instOutput {
                        output.instaPickSuccess(isOn: false)
                        output.syncStatusSuccess(status: false)
                    }
                }
            }
        }, fail: { errorResponse in
            DispatchQueue.toMain {
                errorResponse.showInternetErrorGlobal()
                failureHandler(errorResponse)
            }
        })
    }
    
    func disconnectAccount() {
        instService.disconnectInstagram { [weak self] response in
            switch response {
            case .success(_):
                DispatchQueue.toMain {
                    self?.instOutput?.disconnectionSuccess()
                }
                
                self?.changeInstaPick(status: false)
                self?.stopSync()
                
            case .failed(let error):
                DispatchQueue.toMain {
                    self?.instOutput?.disconnectionFailure(errorMessage: error.description)
                }
            }
        }
    }
    
    func setInstaPick(status: Bool) {
        
        let failureHandler: FailResponse = { [weak self] errorResponse in
            if let output = self?.instOutput {
                output.connectionFailure(errorMessage: errorResponse.description)
                output.instaPickFailure(errorMessage: errorResponse.description)
            }
        }
        
        instService.socialStatus(success: { [weak self] response in
            guard let response = response as? SocialStatusResponse,
                let isConnected = response.instagram
                else {
                    return
            }
            
            DispatchQueue.toMain {
                self?.instOutput?.connectionSuccess(isConnected: isConnected, username: response.instagramUsername)
            }
            
            if isConnected || !status {
                self?.changeInstaPick(status: status)
            } else if status {
                self?.getConfig()
            }

            }, fail: { errorResponse in
                DispatchQueue.toMain {
                    errorResponse.showInternetErrorGlobal()
                    failureHandler(errorResponse)
                }
        })
    }
    
    func setSync(status: Bool) {
        let failureHandler: FailResponse = { [weak self] errorResponse in
            if let output = self?.instOutput {
                output.connectionFailure(errorMessage: errorResponse.description)
                if status {
                    output.startSyncFailure(errorMessage: errorResponse.description)
                } else {
                    output.stopSyncFailure(errorMessage: errorResponse.description)
                }
            }
        }
        
        instService.socialStatus(success: { [weak self] response in
            guard let response = response as? SocialStatusResponse,
                let isConnected = response.instagram
                else {
                    return
            }
            
            DispatchQueue.toMain {
                self?.instOutput?.connectionSuccess(isConnected: isConnected, username: response.instagramUsername)
            }
            
            if isConnected {
                if status {
                    self?.startSync()
                } else {
                    self?.stopSync()
                }
            } else if status {
                self?.getConfig()
            }
            }, fail: { errorResponse in
                DispatchQueue.toMain {
                    errorResponse.showInternetErrorGlobal()
                    failureHandler(errorResponse)
                }
        })
    }
    
    private func changeInstaPick(status: Bool) {
        accountService.changeInstapickAllowed(isInstapickAllowed: status) { [weak self] response in
            guard let `self` = self else {
                return
            }
            
            switch response {
            case .success(let permissions):
                DispatchQueue.toMain {
                    self.instOutput?.instaPickSuccess(isOn: permissions.isInstapickAllowed ?? false)
                }
            case .failed(let error):
                DispatchQueue.toMain {
                    self.instOutput?.instaPickFailure(errorMessage: error.description)
                }
            }
        }
    }
    
    private func getInstaPickStatus() {
        accountService.getSettingsInfoPermissions { [weak self] response in
            switch response {
            case .success(let permissions):
                DispatchQueue.toMain {
                    self?.instOutput?.instaPickSuccess(isOn: permissions.isInstapickAllowed ?? false)
                }
            case .failed(let error):
                DispatchQueue.toMain {
                    self?.instOutput?.instaPickFailure(errorMessage: error.description)
                }
            }
        }
    }
    
    private func getSyncStatus() {
        instService.getSyncStatus(success: { [weak self] response in
            guard let response = response as? SocialSyncStatusResponse,
                let status = response.status
                else {
                    return
            }
            
            DispatchQueue.main.async {
                self?.instOutput?.syncStatusSuccess(status: status)
            }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.instOutput?.syncStatusFailure(errorMessage: errorResponse.description)
                }
        })
    }
    
    private func getConfig() {
        instService.getInstagramConfig(success: { [weak self] response in
            guard let response = response as? InstagramConfigResponse else { return }
            DispatchQueue.main.async {
                self?.instOutput?.configSuccess(instagramConfig: response)
            }
        }, fail: { [weak self] errorResponse in
            DispatchQueue.main.async {
                self?.instOutput?.configFailure(errorMessage: errorResponse.description)
            }
        })
    }
    
    private func startSync() {
        let params = SocialSyncStatusParametrs(status: true)
        instService.setSyncStatus(param: params, success: { [weak self] response in
            guard let _ = response as? SendSocialSyncStatusResponse else { return }
            
            self?.uploadCurrent()
            DispatchQueue.main.async {
                self?.instOutput?.startSyncSuccess()
            }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.instOutput?.startSyncFailure(errorMessage: errorResponse.description)
                }
        })
    }
    
    private func stopSync() {
        let params = SocialSyncStatusParametrs(status: false)
        instService.setSyncStatus(param: params, success: { [weak self] response in
            guard let _ = response as? SendSocialSyncStatusResponse else { return }
            
            self?.cancelUpload()
            DispatchQueue.main.async {
                self?.instOutput?.stopSyncSuccess()
            }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.instOutput?.stopSyncFailure(errorMessage: errorResponse.description)
                }
        })
    }
    
    private func uploadCurrent() {
        instService.createMigration(success: { [weak self] response in
            guard let _ = response as? CreateMigrationResponse else { return }
            DispatchQueue.main.async {
                self?.instOutput?.uploadCurrentSuccess()
            }
        }, fail: { [weak self] errorResponse in
            DispatchQueue.main.async {
                self?.instOutput?.uploadCurrentFailure(errorMessage: errorResponse.description)
            }
        })
    }
    
    private func cancelUpload() {
        instService.cancelMigration(success: { [weak self] response in
            guard let _ = response as? CancelMigrationResponse else { return }
            DispatchQueue.main.async {
                self?.instOutput?.cancelUploadSuccess()
            }
        }, fail: { [weak self] errorResponse in
            DispatchQueue.main.async {
                self?.instOutput?.cancelUploadFailure(errorMessage: errorResponse.description)
            }
        })
    }
    
    func trackImportStatusInstagram(isOn: Bool) {
        analyticsService.trackConnectedAccountsGAEvent(action: .importFrom, label: .instagram, dimension: .statusType, status: isOn)
    }
    
    func trackConnectionStatusInstagram(isConnected: Bool) {
        analyticsService.trackConnectedAccountsGAEvent(action: .connectedAccounts, label: .instagram, dimension: .connectionStatus, status: isConnected)
    }
    
}
