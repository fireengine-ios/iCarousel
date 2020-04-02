//
//  ImportPhotosPresenter.swift
//  Depo
//
//  Created by Maksim Rahleev on 04.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

// MARK: - Facebook

/**
 [Facebook flow](https://wiki.life.com.by/display/LTFizy/Facebook+Import+flow)

 [Facebook profile settings (To test facebook login)](https://web.facebook.com/settings?tab=applications)
 */
class ImportFromFBPresenter: BasePresenter {
    
    weak var view: ImportFromFBViewInput?
    var interactor: ImportFromFBInteractorInput!
    
    var importIsAwaiting = false
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
}

// MARK: - ImportFromFBViewOutput
extension ImportFromFBPresenter: ImportFromFBViewOutput {

    func viewIsReady() {
        view?.startActivityIndicator()
        view?.startActivityIndicator()
        
        interactor.getAllStatuses()
    }
    
    func disconnectAccount() {
        view?.startActivityIndicator()
        
        interactor.disconnectAccount()
    }
    
    func startImport() {
        view?.startActivityIndicator()
        
        importIsAwaiting = true
        interactor.setImport(status: true)
    }
    
    func stopImport() {
        view?.startActivityIndicator()
        
        interactor.setImport(status: false)
    }
}


// MARK: - ImportFromFBInteractorOutput
extension ImportFromFBPresenter: ImportFromFBInteractorOutput {
    func tokenSuccess(token: String) {
        interactor.connect(withToken: token)
    }
    
    func tokenFailure(errorMessage: String) {
        view?.stopActivityIndicator()
        
        if errorMessage != TextConstants.NotLocalized.facebookLoginCanceled {
            view?.connectionStatusSuccess(false)
        }
        interactor.requestSyncStatus()
    }
    
    
    // MARK: connection
    
    func connectionSuccess(isConnected: Bool) {
        view?.stopActivityIndicator()
        
        if isConnected {
            view?.connectionStatusSuccess(isConnected)
            interactor.trackConnectionStatusFB(isConnected: true)
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
        interactor.trackConnectionStatusFB(isConnected: false)
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
            analyticsService.track(event: .importFacebook)
        } else {
            view?.importStopSuccess()
        }
    }
    
    func syncStatusFailure(errorMessage: String) {
        view?.stopActivityIndicator()
        view?.syncStatusFailure()
    }
    
    
    // MARK: import
    
    func startImportSuccess() {
        view?.stopActivityIndicator()
        
        importIsAwaiting = false
        
        interactor.trackImportStatusFB(isOn: true)
        analyticsService.track(event: .importFacebook)
        view?.importStartSuccess()
    }
    
    func startImportFailure(errorMessage: String) {
        view?.stopActivityIndicator()
        
        importIsAwaiting = false
        view?.importStartFailure(errorMessage: errorMessage)
    }
    
    func stopImportSuccess() {
        view?.stopActivityIndicator()
        view?.importStopSuccess()
    }
    
    func stopImportFailure(errorMessage: String) {
        view?.stopActivityIndicator()
        view?.importStopFailure(errorMessage: errorMessage)
    }
    
    
    // MARK: authorization
    
    func connectionWithTokenSuccess() {
        if importIsAwaiting {
            startImport()
        }
        self.view?.stopActivityIndicator()
    }
    
    func connectionWithTokenFailure(errorMessage: String) {
        if importIsAwaiting {
            view?.syncStatusSuccess(false)
        }
        view?.stopActivityIndicator()
    }
    
    // MARK: Permissions
    
    func permissionsSuccess(permissions: FBPermissionsObject) {
        view?.startActivityIndicator()
        var perms = [String]()
        if let readPerms = permissions.read {
            perms += readPerms
        }
        /// MAYBE WILL BE NEED
        //if let writePerms = permissions.write {
        //    perms += writePerms
        //}
        interactor.requestToken(permissions: perms)
    }
    
    func permissionsFailure(errorMessage: String) {
        view?.stopActivityIndicator()
        interactor.requestSyncStatus()
    }
}
