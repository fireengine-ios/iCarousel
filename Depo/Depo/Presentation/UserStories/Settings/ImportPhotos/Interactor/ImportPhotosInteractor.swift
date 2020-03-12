//
//  ImportPhotosInteractor.swift
//  Depo
//
//  Created by Maksim Rahleev on 04.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class ImportFromFBInteractor: ImportFromFBInteractorInput {

    weak var output: ImportFromFBInteractorOutput?
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private let fbService = FBService()
    
    
    func getAllStatuses() {
        let failureHandler: FailResponse = { [weak self] errorResponse in
            if let output = self?.output {
                output.connectionFailure(errorMessage: errorResponse.description)
                output.startImportFailure(errorMessage: errorResponse.description)
            }
        }
        
        fbService.socialStatus(success: { [weak self] response in
            guard let response = response as? SocialStatusResponse,
                let isConnected = response.facebook
            else {
                return
            }
            
            DispatchQueue.toMain {
                self?.output?.connectionSuccess(isConnected: isConnected)
            }
            
            if isConnected {
                self?.requestSyncStatus()
            } else {
                DispatchQueue.toMain {
                    self?.output?.stopImportSuccess()
                }
            }
        }) { errorResponse in
            DispatchQueue.toMain {
                errorResponse.showInternetErrorGlobal()
                failureHandler(errorResponse)
            }
        }
    }
    
    func disconnectAccount() {
        fbService.disconnectFacebook { [weak self] response in
            switch response {
            case .success(_):
                DispatchQueue.toMain {
                    self?.output?.disconnectionSuccess()
                }
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Import(status: .off, socialType: .facebook))
                self?.stopImport()
                
            case .failed(let error):
                DispatchQueue.toMain {
                    self?.output?.disconnectionFailure(errorMessage: error.description)
                }
            }
        }
    }
    
    func setImport(status: Bool) {
        let failureHandler: FailResponse = { [weak self] errorResponse in
            if let output = self?.output {
                output.connectionFailure(errorMessage: errorResponse.description)
                if status {
                    output.startImportFailure(errorMessage: errorResponse.description)
                } else {
                    output.stopImportFailure(errorMessage: errorResponse.description)
                }
            }
        }
        
        fbService.socialStatus(success: { [weak self] response in
            guard let response = response as? SocialStatusResponse,
                let isConnected = response.facebook
            else {
                return
            }
            
            DispatchQueue.toMain {
                self?.output?.connectionSuccess(isConnected: isConnected)
            }
            
            if isConnected {
                if status {
                    self?.startImport()
                } else {
                    self?.stopImport()
                }
            } else if status {
                self?.requestPermissions()
            }
            }, fail: { errorResponse in
                DispatchQueue.toMain {
                    errorResponse.showInternetErrorGlobal()
                    failureHandler(errorResponse)
                }
        })
    }
    
    private func startImport() {
        fbService.requestStart(success: { [weak self] _ in
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Import(status: .on, socialType: .facebook))
            DispatchQueue.main.async {
                self?.output?.startImportSuccess()
            }
        }) { [weak self] error in
            DispatchQueue.main.async {
                self?.output?.startImportFailure(errorMessage: error.description)
            }
        }
    }
    
    private func stopImport() {
        fbService.requestStop(success: { [weak self] _ in
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Import(status: .off, socialType: .facebook))
            DispatchQueue.main.async {
                self?.output?.stopImportSuccess()
            }
        }) { [weak self] error in
            DispatchQueue.main.async {
                self?.output?.stopImportFailure(errorMessage: error.description)
            }
        }
    }
    
    func requestPermissions() {
        fbService.requestPermissions(success: { [weak self] responseObject in
            let fbPermissions = responseObject as! FBPermissionsObject
            DispatchQueue.main.async {
                self?.output?.permissionsSuccess(permissions: fbPermissions)
            }
        }) { [weak self] error in
            DispatchQueue.main.async {
                self?.output?.permissionsFailure(errorMessage: error.description)
            }
        }
    }
    
    func requestToken(permissions: [String]) {
        fbService.requestToken(permissions: permissions, success: { [weak self] token in
            DispatchQueue.main.async {
                self?.output?.tokenSuccess(token: token)
            }
        }) { [weak self] error in
            DispatchQueue.main.async {
                self?.output?.tokenFailure(errorMessage: error.description)
            }
        }
    }
    
    func connect(withToken token: String) {
        fbService.requestConnect(withToken: token, success: { [weak self] response in
            DispatchQueue.main.async {
                self?.output?.connectionWithTokenSuccess()
            }
        }) { [weak self] error in
            DispatchQueue.main.async {
                self?.output?.connectionWithTokenFailure(errorMessage: error.description)
            }
        }
    }
    
    func requestSyncStatus() {
        fbService.requestStatus(success: { [weak self] responseObject in
            let fbStatus = responseObject as? FBStatusObject
            DispatchQueue.main.async {
                self?.output?.syncStatusSuccess(status: fbStatus?.syncEnabled ?? false)
            }
        }) { [weak self] error in
            DispatchQueue.main.async {
                self?.output?.syncStatusFailure(errorMessage: error.description)
            }
        }
    }

    func trackImportActivationFB() {
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .importFrom, eventLabel: .importFacebook)
    }
}
