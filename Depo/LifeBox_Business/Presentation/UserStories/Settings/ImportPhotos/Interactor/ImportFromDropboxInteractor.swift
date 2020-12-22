//
//  ImportFromDropboxInteractor.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/9/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

class ImportFromDropboxInteractor {
    weak var output: ImportFromDropboxInteractorOutput?
    
    private var dbService = DropboxService()
    private lazy var dropboxManager: DropboxManager = factory.resolve()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
}

extension ImportFromDropboxInteractor: ImportFromDropboxInteractorInput {
    
    func getAllStatuses() {
        requestStatusBaseRequest { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let status):
                    self?.output?.statusSuccess(status: status)
                case .failed(let error):
                    let errorMessage = (error as? ErrorResponse)?.description ?? error.description
                    self?.output?.statusFailure(errorMessage: errorMessage)
                }
            }
        }
    }
    
    func connect(withToken token: String) {
        dbService.requestConnect(withToken: token, success: { [weak self] _ in
            DispatchQueue.main.async {
                self?.output?.connectWithTokenSuccess()
            }
            }, fail: { [weak self] error in
                DispatchQueue.main.async {
                    self?.dropboxManager.logout()
                    self?.login()
                    self?.output?.connectWithTokenFailure(errorMessage: error.description)
                }
        })
    }

    func disconnectAccount() {
        dbService.disconnectDropbox { [weak self] response in
            switch response {
            case .success(_):
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Import(status: .off, socialType: .dropbox))
                self?.output?.disconnectionSuccess()
            case .failed(let error):
                self?.output?.disconnectionFailure(errorMessage: error.description)
            }
        }
    }
    
    func startImport() {
        let failureHandler: FailResponse = { [weak self] errorResponse in
            DispatchQueue.toMain {
                if let output = self?.output {
                    output.startFailure(errorMessage: errorResponse.description)
                    output.statusFailure(errorMessage: errorResponse.description)
                }
            }
        }
        
        dbService.requestStatus(success: { [weak self] response in
            if let dropboxStatus = response as? DropboxStatusObject {
                self?.output?.statusSuccess(status: dropboxStatus)
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Import(status: .on, socialType: .dropbox))
                if dropboxStatus.connected ?? false {
                    self?.requestStart()
                } else {
                    self?.login()
                }
            } else {
                failureHandler(ErrorResponse.string("wrong DropboxStatusObject"))
            }
        }, fail: failureHandler)
    }

    func login() {
        dropboxManager.logout()
        dropboxManager.login { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    self?.output?.loginSuccess(token: token)
                case .cancel:
                    self?.output?.loginCanceled()
                case .failed(let errorString):
                    self?.output?.loginFailure(errorMessage: errorString)
                }
            }
        }
    }
    
    func requestStatusForStart() {
        requestStatusBaseRequest { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let status):
                    self?.output?.statusForStartSuccess(status: status)
                case .failed(let error):
                    if let errorResponse = error as? ErrorResponse,
                        case ErrorResponse.error(let error) = errorResponse,
                        error.isNetworkError 
                    {
                        self?.output?.failedWithInternetError(errorMessage: error.description)
                    }
                    self?.output?.statusForStartFailure(errorMessage: error.description)
                }
            }
        }
    }
    
    func requestStart() {
        dbService.requestStart(success: { [weak self] _ in
            DispatchQueue.main.async {
                self?.output?.startSuccess()
            }
        }, fail: { [weak self] error in
            DispatchQueue.main.async {
                self?.output?.startFailure(errorMessage: error.description)
            }
        })
    }
    
    func requestStatusForCompletion() {
        requestStatusBaseRequest { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let status):
                    self?.output?.statusForCompletionSuccess(dropboxStatus: status)
                case .failed(let error):
                    let errorMessage = (error as? ErrorResponse)?.description ?? error.description
                    self?.output?.statusForCompletionFailure(errorMessage: errorMessage)
                }
            }
        }
    }
    
    private func requestStatusBaseRequest(handler: @escaping (ResponseResult<DropboxStatusObject>) -> Void) {
        dbService.requestStatus(success: { responseObject in
            if let dropboxStatus = responseObject as? DropboxStatusObject {
                handler(ResponseResult.success(dropboxStatus))
            } else {
                handler(ResponseResult.failed(CustomErrors.unknown))
            }
        }, fail: { errorResponse in
            handler(ResponseResult.failed(errorResponse))
        })
    }
    
    func trackImportStatusDropBox(isOn: Bool) {
        analyticsService.trackConnectedAccountsGAEvent(action: .importFrom, label: .dropbox, dimension: .statusType, status: isOn)
    }
    
    func trackConnectionStatusDropBox(isConnected: Bool) {
        analyticsService.trackConnectedAccountsGAEvent(action: .connectedAccounts, label: .dropbox, dimension: .connectionStatus, status: isConnected)
    }
    
}
