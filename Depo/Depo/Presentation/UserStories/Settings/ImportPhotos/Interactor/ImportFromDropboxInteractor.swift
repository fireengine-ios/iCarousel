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
    
    func requestStatus() {
        requestStatusBaseRequest { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let status):
                    self?.output?.statusSuccessCallback(status: status)
                case .failed(let error):
                    let errorMessage = (error as? ErrorResponse)?.description ?? error.description
                    self?.output?.statusFailureCallback(errorMessage: errorMessage)
                }
            }
        }
    }
    
    func login() {
        dropboxManager.login { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    self?.output?.loginSuccessCallback(token: token)
                case .cancel:
                    self?.output?.loginCanceled()
                case .failed(let errorString):
                    self?.output?.loginFailureCallback(errorMessage: errorString)
                }
            }
        }
    }
    
    func requestConnect(withToken token: String) {
        dbService.requestConnect(withToken: token, success: { [weak self] _ in
            DispatchQueue.main.async {
                self?.output?.connectSuccessCallback()
            }
        }, fail: { [weak self] error in
            DispatchQueue.main.async {
                self?.dropboxManager.logout()
                self?.login()
                self?.output?.connectFailureCallback(errorMessage: error.description)
            }
        })
    }
    
    func requestStatusForStart() {
        requestStatusBaseRequest { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let status):
                    self?.output?.statusForStartSuccessCallback(status: status)
                case .failed(let error):
                    if let errorResponse = error as? ErrorResponse,
                        case ErrorResponse.error(let error) = errorResponse,
                        error.isNetworkError 
                    {
                        self?.output?.failedWithInternetError(errorMessage: error.description)
                    }
                    self?.output?.statusForStartFailureCallback(errorMessage: error.description)
                }
            }
        }
    }
    
    func requestStart() {
        dbService.requestStart(success: { [weak self] _ in
            DispatchQueue.main.async {
                self?.output?.startSuccessCallback()
            }
        }, fail: { [weak self] error in
            DispatchQueue.main.async {
                self?.output?.startFailureCallback(errorMessage: error.description)
            }
        })
    }
    
    func requestStatusForCompletion() {
        requestStatusBaseRequest { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let status):
                    self?.output?.statusForCompletionSuccessCallback(dropboxStatus: status)
                case .failed(let error):
                    let errorMessage = (error as? ErrorResponse)?.description ?? error.description
                    self?.output?.statusForCompletionFailureCallback(errorMessage: errorMessage)
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
    
    func trackImportActivationDropBox() {
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .importFrom, eventLabel: .importDropbox)
    }
}
