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
}

// MARK: - ImportFromDropboxViewOutput
extension ImportFromDropboxPresenter: ImportFromDropboxViewOutput {
    func viewIsReady() {
        view?.startActivityIndicator()
        interactor.requestStatus()
    }
    
    func startDropbox() {
        view?.startActivityIndicator()
        interactor.requestStatusForStart()
    }
}

// MARK: - ImportFromDropboxInteractorOutput
extension ImportFromDropboxPresenter: ImportFromDropboxInteractorOutput {
    
    // MARK: status
    
    func statusSuccessCallback(status: DropboxStatusObject) {
//        view?.dbStatusSuccessCallback(status: status)
        view?.stopActivityIndicator()
//        view?.startStatus()
//        interactor.requestStatusForCompletion()
        
        guard let requestStatus = status.status else {
            return
        }
        
        switch requestStatus {
        case .scheduled, .waitingAction, .running, .pending:
            view?.startStatus()
            statusForCompletionSuccessCallback(dropboxStatus: status)
        case .finished, .failed, .cancelled, .none:
            view?.stopStatus()
        }
    }
    
    func statusFailureCallback(errorMessage: String) {  
//        view?.dbStatusFailureCallback()
        view?.stopActivityIndicator()
    }
    
    // MARK: - StatusForCompletion
    
    func statusForCompletionSuccessCallback(dropboxStatus: DropboxStatusObject) {
        guard let requestStatus = dropboxStatus.status else {
            view?.stopStatus()
            return
        }
        
        switch requestStatus {
        case .scheduled, .waitingAction, .pending:
            view?.updateStatus(progressPercent: 0)
            interactor.requestStatusForCompletion()
        case .running:
            view?.updateStatus(progressPercent: dropboxStatus.progress ?? 0)
            interactor.requestStatusForCompletion()
        case .finished, .failed, .cancelled, .none:
            view?.stopStatus()
        }
        
//        view?.dbStatusSuccessCallback(status: dropboxstatus)
//        view?.stopActivityIndicator()
    }
    
    func statusForCompletionFailureCallback(errorMessage: String) {
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
        view?.startStatus()
        interactor.requestStatusForCompletion()
    }
    
    func startFailureCallback(errorMessage: String) {
        view?.stopActivityIndicator()
        view?.failedDropboxStart(errorMessage: errorMessage)
    }
}
