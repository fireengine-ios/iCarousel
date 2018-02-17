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
}

extension ImportFromInstagramInteractor: ImportFromInstagramInteractorInput {
    
    func getConnectionStatus() {
        instService.socialStatus(success: { [weak self] response in
            guard let response = response as? SocialStatusResponse,
                let isConnected = response.instagram
                else { return }
            if isConnected {
                self?.getSyncStatus()
            } else {
                DispatchQueue.main.async {
                    self?.instOutput?.syncStatusFailure(errorMessage: "Instagram is not connected")
                }
            }
        }, fail: { [weak self] errorResponse in
            DispatchQueue.main.async {
                errorResponse.showInternetErrorGlobal()
                self?.instOutput?.syncStatusFailure(errorMessage: errorResponse.description)
            }
        })
    }
    
    private func getSyncStatus() {
        instService.getSyncStatus(success: { [weak self] response in
            guard let response = response as? SocialSyncStatusResponse,
                let status = response.status
                else { return }
            DispatchQueue.main.async {
                self?.instOutput?.syncStatusSuccess(status: status)
            }
        }, fail: { [weak self] errorResponse in
            DispatchQueue.main.async {
                self?.instOutput?.syncStatusFailure(errorMessage: errorResponse.description)
            }
        })
    }
    
    func getConnection() {
        instService.socialStatus(success: { [weak self] response in
            guard let response = response as? SocialStatusResponse,
                let isConnected = response.instagram
                else { return }
            DispatchQueue.main.async {
                self?.instOutput?.connectionSuccess(isConnected: isConnected)
            }
        }, fail: { [weak self] errorResponse in
            DispatchQueue.main.async {
                self?.instOutput?.connectionFailure(errorMessage: errorResponse.description)
            }
        })
    }
    
    func getConfig() {
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
    
    func setAsync(status: Bool) {
        let params = SocialSyncStatusParametrs(status: status)
        instService.setSyncStatus(param: params, success: { [weak self] response in
            guard let _ = response as? SendSocialSyncStatusResponse else { return }
            DispatchQueue.main.async {
                if status {
                    self?.instOutput?.startAsyncSuccess()
                } else {
                    self?.instOutput?.stopAsyncSuccess()
                }
            }
        }, fail: { [weak self] errorResponse in
            DispatchQueue.main.async {
                if status {
                    self?.instOutput?.startAsyncFailure(errorMessage: errorResponse.description)
                } else {
                    self?.instOutput?.stopAsyncFailure(errorMessage: errorResponse.description)
                }
            }
        })
    }
    
    func uploadCurrent() {
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
    
    func cancelUpload() {
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
}
