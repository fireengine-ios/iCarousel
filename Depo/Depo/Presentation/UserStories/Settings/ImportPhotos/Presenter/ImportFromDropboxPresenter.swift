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
//    var router: ImportFromDropboxRouterInput!
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    private var importIsAwaiting = false

    private let lastUpdateEmptyMessage = " "
}

// MARK: - ImportFromDropboxViewOutput
extension ImportFromDropboxPresenter: ImportFromDropboxViewOutput {
    func viewIsReady() {
        view?.startActivityIndicator()
        
        interactor.getAllStatuses()
    }
    
    func disconnectAccount() {
        view?.startActivityIndicator()
        
        interactor.disconnectAccount()
    }
    
    func startDropbox() {
        view?.startActivityIndicator()
        
        importIsAwaiting = true
        interactor.startImport()
    }
}

// MARK: - ImportFromDropboxInteractorOutput
extension ImportFromDropboxPresenter: ImportFromDropboxInteractorOutput {
    
    // MARK: status
    func statusSuccess(status: DropboxStatusObject) {
        view?.stopActivityIndicator()
        
        if let isConnected = status.connected {
            view?.connectionStatusSuccess(isConnected)
        }

        guard let requestStatus = status.status else {
            return
        }
        
        switch requestStatus {
        case .scheduled, .waitingAction, .running, .pending:
            view?.startDropboxStatus()
            statusForCompletionSuccess(dropboxStatus: status)
        case .finished, .failed, .cancelled, .none:
            view?.stopDropboxStatus(lastUpdateMessage: status.uploadDescription)
        }
    }
    
    func statusFailure(errorMessage: String) {
        view?.stopActivityIndicator()
        view?.connectionStatusFailure(errorMessage: errorMessage)
    }
    
    func disconnectionSuccess() {
        interactor.trackConnectionStatusDropBox(isConnected: false)
        view?.stopActivityIndicator()
        view?.disconnectionSuccess()
    }
    
    func disconnectionFailure(errorMessage: String) {
        view?.stopActivityIndicator()
        view?.disconnectionFailure(errorMessage: errorMessage)
    }
    
    
    // MARK: - StatusForCompletion
    
    func statusForCompletionSuccess(dropboxStatus: DropboxStatusObject) {
        guard let requestStatus = dropboxStatus.status else {
            view?.stopDropboxStatus(lastUpdateMessage: dropboxStatus.uploadDescription)
            return
        }
        
        if let isConnected = dropboxStatus.connected {
            view?.connectionStatusSuccess(isConnected)
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
    
    func statusForCompletionFailure(errorMessage: String) {
        view?.stopDropboxStatus(lastUpdateMessage: lastUpdateEmptyMessage)
        view?.failedDropboxStart(errorMessage: errorMessage)
    }
    
    // MARK: status for start
    
    func statusForStartSuccess(status: DropboxStatusObject) {
        if status.connected == true {
            interactor.requestStart()
        } else {
            interactor.login()
        }
    }
    
    func statusForStartFailure(errorMessage: String) {
        interactor.login()
    }
    
    func failedWithInternetError(errorMessage: String) {
        view?.stopActivityIndicator()
        view?.failedDropboxStart(errorMessage: errorMessage)
    }
    
    // MARK: login, Token
    
    func loginSuccess(token: String) {
        interactor.trackConnectionStatusDropBox(isConnected: true)
        interactor.connect(withToken: token)
    }
    
    func loginFailure(errorMessage: String) {
        view?.stopActivityIndicator()
        view?.failedDropboxStart(errorMessage: errorMessage)
    }
    
    func loginCanceled() {
        view?.stopActivityIndicator()
    }
    
    // MARK: connect with token
    
    func connectWithTokenSuccess() {
        if importIsAwaiting {
            interactor.requestStart()
        }
    }
    
    func connectWithTokenFailure(errorMessage: String) {
        view?.stopActivityIndicator()
        view?.failedDropboxStart(errorMessage: errorMessage)
    }
    
    // MARK: start
    
    func startSuccess() {
        importIsAwaiting = false
        view?.stopActivityIndicator()
        view?.startDropboxStatus()
        interactor.requestStatusForCompletion()
        interactor.trackImportStatusDropBox(isOn: true)
        analyticsService.track(event: .importDropbox)
    }
    
    func startFailure(errorMessage: String) {
        importIsAwaiting = false
        view?.stopActivityIndicator()
        view?.failedDropboxStart(errorMessage: errorMessage)
        interactor.trackImportStatusDropBox(isOn: false)
    }
    
}
