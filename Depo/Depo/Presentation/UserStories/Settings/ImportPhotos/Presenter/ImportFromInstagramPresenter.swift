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
    
    private var syncIsAwaiting = false
    private var instaPickIsAwaiting = false
}

// MARK: - ImportFromInstagramViewOutput
extension ImportFromInstagramPresenter: ImportFromInstagramViewOutput {
    func viewIsReady() {
        ///+ 2 calls inside the getAllStatuses()
        view?.startActivityIndicator()
        view?.startActivityIndicator()
        view?.startActivityIndicator()
        
        interactor.getAllStatuses()
    }
    
    func disconnectAccount() {
        view?.startActivityIndicator()
        interactor.disconnectAccount()
    }
    
    func startInstagram() {
        view?.startActivityIndicator()
        view?.startActivityIndicator()
        
        syncIsAwaiting = true
        interactor.setSync(status: true)
        interactor.trackImportActivationInstagram()
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Import(status: .on, socialType: .instagram))
    }
    
    func stopInstagram() {
        view?.startActivityIndicator()
        view?.startActivityIndicator()
        MenloworksTagsService.shared.instagramImport(isOn: false)
        interactor.setSync(status: false)
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Import(status: .off, socialType: .instagram))
    }
    
    func enableInstaPick() {
        instaPickIsAwaiting = true
        view?.startActivityIndicator()
        interactor.setInstaPick(status: true)
    }
    
    func disableInstaPick() {
        view?.startActivityIndicator()
        interactor.setInstaPick(status: false)
    }

}

// MARK: - ImportFromInstagramInteractorOutput
extension ImportFromInstagramPresenter: ImportFromInstagramInteractorOutput {

    func instaPickSuccess(isOn: Bool) {
        ///TODO: Menloworks?
        ///TODO: analytics?
        instaPickIsAwaiting = false
        view?.stopActivityIndicator()
        view?.instaPickStatusSuccess(isOn)
    }
    
    func instaPickFailure(errorMessage: String) {
        instaPickIsAwaiting = false
        UIApplication.showErrorAlert(message: errorMessage)
        view?.stopActivityIndicator()
        view?.instaPickStatusFailure()
    }

    // MARK: connection

    func connectionSuccess(isConnected: Bool, username: String?) {
        view?.stopActivityIndicator()
        
        if isConnected {
            MenloworksAppEvents.onInstagramConnected()
            view?.connectionStatusSuccess(isConnected, username: username)
        }
    }

    func connectionFailure(errorMessage: String) {
        UIApplication.showErrorAlert(message: errorMessage)
        view?.stopActivityIndicator()
        view?.connectionStatusFailure(errorMessage: errorMessage)
    }
    
    func disconnectionSuccess() {
        view?.stopActivityIndicator()
        view?.disconnectionSuccess()
    }
    
    func disconnectionFailure(errorMessage: String) {
        view?.stopActivityIndicator()
        view?.disconnectionFailure(errorMessage: errorMessage)
    }
    
    // MARK: sync status
    
    func syncStatusSuccess(status: Bool) {
        view?.stopActivityIndicator()
        if status {
            view?.syncStatusSuccess(status)
            analyticsService.track(event: .importInstagram)
        } else {
            view?.syncStatusFailure()
        }
    }
    
    func syncStatusFailure(errorMessage: String) {
        view?.stopActivityIndicator()
        view?.syncStatusFailure()
    }
    
    // MARK: config
    
    func configSuccess(instagramConfig: InstagramConfigResponse) {
        view?.stopActivityIndicator()
        router.openInstagramAuth(param: instagramConfig, delegate: self)
    }

    func configFailure(errorMessage: String) {
        view?.stopActivityIndicator()
        view?.syncStartFailure(errorMessage: errorMessage)
    }
    
    // MARK: startAsync
    
    func startSyncSuccess() {
        syncIsAwaiting = false
        
        view?.stopActivityIndicator()
        view?.syncStartSuccess()
        analyticsService.track(event: .importInstagram)
    }
    
    func startSyncFailure(errorMessage: String) {
        syncIsAwaiting = false
        
        view?.stopActivityIndicator()
        view?.syncStartFailure(errorMessage: errorMessage)
    }
    
    // MARK: uploadCurrent
    
    func uploadCurrentSuccess() {
        view?.stopActivityIndicator()
        view?.syncStartSuccess()
    }
    
    func uploadCurrentFailure(errorMessage: String) {
        view?.stopActivityIndicator()
        view?.syncStartFailure(errorMessage: errorMessage)
    }
    
    // MARK: stopSync
    
    func stopSyncSuccess() {
        view?.stopActivityIndicator()
        view?.syncStopSuccess()
    }
    
    func stopSyncFailure(errorMessage: String) {
        view?.stopActivityIndicator()
        view?.syncStopFailure(errorMessage: errorMessage)
    }
    
    // MARK: cancelUpload
    
    func cancelUploadSuccess() {
        view?.stopActivityIndicator()
        view?.syncStopSuccess()
    }
    
    func cancelUploadFailure(errorMessage: String) {
        view?.stopActivityIndicator()
        view?.syncStopFailure(errorMessage: errorMessage)
    }
}

// MARK: - InstagramAuthViewControllerDelegate
extension ImportFromInstagramPresenter: InstagramAuthViewControllerDelegate {
    
    func instagramAuthSuccess() {
        view?.startActivityIndicator()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { /// + 1 for backend bug
            if self.instaPickIsAwaiting {
                self.enableInstaPick()
            } else if self.syncIsAwaiting {
                self.startInstagram()
            }
            
            self.view?.stopActivityIndicator()
        }
    }
    
    func instagramAuthCancel() {
        if self.instaPickIsAwaiting {
            self.instaPickSuccess(isOn: false)
        } else if self.syncIsAwaiting {
            self.syncStatusSuccess(status: false)
        }
        view?.syncStartFailure(errorMessage: TextConstants.NotLocalized.instagramLoginCanceled)
    }
}
