//
//  ImportFromInstagramPresenter.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/22/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

/**
    Will help for testing
    https://www.instagram.com/dmitriytester/
 
    Requests and info in
    Package9_19_2 TT_v5.docx
*/
class ImportFromInstagramPresenter: BasePresenter {
    weak var view: ImportFromInstagramViewInput?
    var interactor: ImportFromInstagramInteractorInput!
    var router: ImportFromInstagramRouterInput!
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
}

// MARK: - ImportFromInstagramViewOutput
extension ImportFromInstagramPresenter: ImportFromInstagramViewOutput {
    func viewIsReady() {
        view?.startActivityIndicator()
        interactor.getConnectionStatus()
    }
    
    func startInstagram() {
        view?.startActivityIndicator()
        interactor.getConnection()
    }
    
    func stopInstagram() {
        view?.startActivityIndicator()
        view?.startActivityIndicator()
        interactor.setAsync(status: false)
        interactor.cancelUpload()
    }
    
    private func start() {
        view?.startActivityIndicator()
        view?.startActivityIndicator()
        interactor.setAsync(status: true)
        interactor.uploadCurrent()
    }
}

// MARK: - ImportFromInstagramInteractorOutput
extension ImportFromInstagramPresenter: ImportFromInstagramInteractorOutput {
    
    // MARK: connection

    func connectionSuccess(isConnected: Bool) {
        if isConnected {
            MenloworksAppEvents.onInstagramConnected()
            start()
            view?.stopActivityIndicator()
        } else {
            interactor.getConfig()
        }
    }

    func connectionFailure(errorMessage: String) {
        UIApplication.showErrorAlert(message: errorMessage)
        view?.stopActivityIndicator()
        view?.instagramStatusFailure()
    }
    
    // MARK: sync status
    
    func syncStatusSuccess(status: Bool) {
        view?.stopActivityIndicator()
        if status == true {
            view?.instagramStatusSuccess()
            analyticsService.track(event: .importInstagram)
        } else {
            view?.instagramStatusFailure()
        }
    }
    
    func syncStatusFailure(errorMessage: String) {
        view?.stopActivityIndicator()
        view?.instagramStatusFailure()
    }
    
    // MARK: config
    
    func configSuccess(instagramConfig: InstagramConfigResponse) {
        view?.stopActivityIndicator()
        router.openInstagramAuth(param: instagramConfig, delegate: self)
    }

    func configFailure(errorMessage: String) {
        view?.stopActivityIndicator()
        view?.instagramStartFailure(errorMessage: errorMessage)
    }
    
    // MARK: startAsync
    
    func startAsyncSuccess() {
        view?.stopActivityIndicator()
        view?.instagramStartSuccess()
        analyticsService.track(event: .importInstagram)
    }
    
    func startAsyncFailure(errorMessage: String) {
        view?.stopActivityIndicator()
        view?.instagramStartFailure(errorMessage: errorMessage)
    }
    
    // MARK: uploadCurrent
    
    func uploadCurrentSuccess() {
        view?.stopActivityIndicator()
        view?.instagramStartSuccess()
    }
    
    func uploadCurrentFailure(errorMessage: String) {
        view?.stopActivityIndicator()
        view?.instagramStartFailure(errorMessage: errorMessage)
    }
    
    // MARK: stopAsync
    
    func stopAsyncSuccess() {
        view?.stopActivityIndicator()
        view?.instagramStopSuccess()
    }
    
    func stopAsyncFailure(errorMessage: String) {
        view?.stopActivityIndicator()
        view?.instagramStopFailure(errorMessage: errorMessage)
    }
    
    // MARK: cancelUpload
    
    func cancelUploadSuccess() {
        view?.stopActivityIndicator()
        view?.instagramStopSuccess()
    }
    
    func cancelUploadFailure(errorMessage: String) {
        view?.stopActivityIndicator()
        view?.instagramStopFailure(errorMessage: errorMessage)
    }
}

// MARK: - InstagramAuthViewControllerDelegate
extension ImportFromInstagramPresenter: InstagramAuthViewControllerDelegate {
    
    func instagramAuthSuccess() {
        view?.startActivityIndicator()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { /// + 1 for backend bug
            self.start()
            self.view?.stopActivityIndicator()
        }
    }
    
    func instagramAuthCancel() {
        view?.instagramStartFailure(errorMessage: "Canceled")
    }
}
