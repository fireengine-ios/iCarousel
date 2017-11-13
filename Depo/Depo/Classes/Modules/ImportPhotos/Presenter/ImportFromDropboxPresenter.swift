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
        view?.dbStatusSuccessCallback(status: status)
        view?.stopActivityIndicator()
    }
    
    func statusFailureCallback(errorMessage: String) {
        view?.dbStatusFailureCallback()
        view?.stopActivityIndicator()
    }
    
    // MARK: status for start
    
    func statusForStartSuccessCallback(status: DropboxStatusObject) {
        if status.connected == true {
            view?.stopActivityIndicator()
        } else {
            interactor.login()
        }   
    }
    
    func statusForStartFailureCallback(errorMessage: String) {
        interactor.login()
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
    }
    
    func startFailureCallback(errorMessage: String) {
        view?.stopActivityIndicator()
        view?.failedDropboxStart(errorMessage: errorMessage)
    }
}
