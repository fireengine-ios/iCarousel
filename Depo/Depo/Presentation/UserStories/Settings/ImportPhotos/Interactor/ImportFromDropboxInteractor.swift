//
//  ImportFromDropboxInteractor.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/9/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

class ImportFromDropboxInteractor {
    var output: ImportFromDropboxInteractorOutput!
    
    var dbService = DropboxService()
    lazy var dropboxManager: DropboxManager = factory.resolve()
}

extension ImportFromDropboxInteractor: ImportFromDropboxInteractorInput {
    
    func requestStatus() {
        dbService.requestStatus(success: { [weak self] responseObject in
            let dropboxStatus = responseObject as! DropboxStatusObject
            DispatchQueue.main.async {
                self?.output.statusSuccessCallback(status: dropboxStatus)
            }
            
        }) { [weak self] error in
            DispatchQueue.main.async {
                self?.output.statusFailureCallback(errorMessage: error.description)
            }
        }
    }
    
    func login() {
        dropboxManager.login { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    self?.output.loginSuccessCallback(token: token)
                case .cancel:
                    self?.output.loginFailureCallback(errorMessage: "Canceled")
                case .failed(let errorString):
                    self?.output.loginFailureCallback(errorMessage: errorString)
                }
            }
        }
    }
    
    func requestConnect(withToken token: String) {
        dbService.requestConnect(withToken: token, success: { [weak self] _ in
            DispatchQueue.main.async {
                self?.output.connectSuccessCallback()
            }
        }) { [weak self] error in
            DispatchQueue.main.async {
                self?.dropboxManager.logout()
                self?.login()
                self?.output.connectFailureCallback(errorMessage: error.description)
            }
        }
    }
    
    func requestStatusForStart() {
        dbService.requestStatus(success: { [weak self] (responseObject) in
            let dropboxStatus = responseObject as! DropboxStatusObject
            DispatchQueue.main.async {
                self?.output.statusForStartSuccessCallback(status: dropboxStatus)
            }
        }) { [weak self] errorResponse in
            DispatchQueue.main.async {
                if case ErrorResponse.error(let error) = errorResponse, error is URLError {
                    self?.output.failedWithInternetError(errorMessage: error.localizedDescription)
                }
                self?.output.statusForStartFailureCallback(errorMessage: errorResponse.localizedDescription)
            }
        }
    }
    
    func requestStart() {
        dbService.requestStart(success: { [weak self] _ in
            DispatchQueue.main.async {
                self?.output.startSuccessCallback()
            }
        }) { [weak self] error in
            DispatchQueue.main.async {
                self?.output.startFailureCallback(errorMessage: error.description)
            }
        }
    }
}
