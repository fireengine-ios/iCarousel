//
//  ImportFromDropboxPresenter.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/9/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

class ImportFromDropboxPresenter: BasePresenter {
    
    weak var view: ImportFromDropboxViewInput?
    var interactor: ImportFromDropboxInteractorInput!
    var router: ImportFromDropboxRouterInput!
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()

    private let lastUpdateEmptyMessage = " "
}

// MARK: - ImportFromDropboxViewOutput
extension ImportFromDropboxPresenter: ImportFromDropboxViewOutput {
    func viewIsReady() {
        view?.startActivityIndicator()
        interactor.requestStatus()
    }
    
    func startDropbox() {
        interactor.login()
    }
}

// MARK: - ImportFromDropboxInteractorOutput
extension ImportFromDropboxPresenter: ImportFromDropboxInteractorOutput {
    
    // MARK: status
    
    func statusSuccessCallback(status: DropboxStatusObject) {
        view?.stopActivityIndicator()
        
        guard let requestStatus = status.status else {
            return
        }
        
        switch requestStatus {
        case .scheduled, .waitingAction, .running, .pending:
            view?.startDropboxStatus()
            statusForCompletionSuccessCallback(dropboxStatus: status)
        case .finished, .failed, .cancelled, .none:
            view?.stopDropboxStatus(lastUpdateMessage: status.uploadDescription)
        }
    }
    
    func statusFailureCallback(errorMessage: String) {  
        view?.stopActivityIndicator()
    }
    
    // MARK: - StatusForCompletion
    
    func statusForCompletionSuccessCallback(dropboxStatus: DropboxStatusObject) {
        guard let requestStatus = dropboxStatus.status else {
            view?.stopDropboxStatus(lastUpdateMessage: dropboxStatus.uploadDescription)
            return
        }
        
        switch requestStatus {
        case .scheduled, .waitingAction, .pending:
            view?.updateDropboxStatus(progressPercent: 0)
            requestStatusForCompletion()
        case .running:
            view?.updateDropboxStatus(progressPercent: dropboxStatus.progress ?? 0)
            requestStatusForCompletion()
        case .finished, .failed, .cancelled, .none:
            view?.stopDropboxStatus(lastUpdateMessage: dropboxStatus.uploadDescription)
        }
    }
    
    private func requestStatusForCompletion() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.interactor.requestStatusForCompletion()
        }
    }
    
    func statusForCompletionFailureCallback(errorMessage: String) {
        view?.stopDropboxStatus(lastUpdateMessage: lastUpdateEmptyMessage)
        view?.failedDropboxStart(errorMessage: errorMessage)
    }
    
    // MARK: status for start
    
    func statusForStartSuccessCallback(status: DropboxStatusObject) {
        if status.connected == true {
            interactor.requestStart()
        } else {
            interactor.login()
        }   
    }
    
    func statusForStartFailureCallback(errorMessage: String) {
        interactor.login()
    }
    
    func failedWithInternetError(errorMessage: String) {
        view?.stopActivityIndicator()
        view?.failedDropboxStart(errorMessage: errorMessage)
    }
    
    // MARK: login, Token
    
    func loginSuccessCallback(token: String) {
        interactor.requestConnect(withToken: token)
    }
    
    func loginFailureCallback(errorMessage: String) {
        view?.stopActivityIndicator()
        view?.failedDropboxStart(errorMessage: errorMessage)
    }
    
    func loginCanceled() {
        view?.stopActivityIndicator()
    }
    
    // MARK: connect
    
    func connectSuccessCallback() {
        interactor.requestStart()
    }
    
    func connectFailureCallback(errorMessage: String) {
        view?.stopActivityIndicator()
        view?.failedDropboxStart(errorMessage: errorMessage)
    }
    
    // MARK: start
    
    func startSuccessCallback() {
        view?.stopActivityIndicator()
        view?.startDropboxStatus()
        interactor.requestStatusForCompletion()
        analyticsService.track(event: .importDropbox)
        interactor.trackImportActivationDropBox()
    }
    
    func startFailureCallback(errorMessage: String) {
        view?.stopActivityIndicator()
        view?.failedDropboxStart(errorMessage: errorMessage)
    }
}
