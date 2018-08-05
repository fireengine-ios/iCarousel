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
    var router: ImportFromFBRouterInput!
    
    var facebookStatus: FBStatusObject?
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
}

// MARK: - ImportFromFBViewOutput
extension ImportFromFBPresenter: ImportFromFBViewOutput {
    
    func viewIsReady() {
        analyticsService.logScreen(screen: .importPhotos)
        analyticsService.trackDimentionsEveryClickGA(screen: .importPhotos)
        view?.startActivityIndicator()
        interactor.requestStatus()
    }
    
    func startFacebook() {
        guard let fbStatus = facebookStatus else {
            interactor.requestStatus()
            return
        }
        if fbStatus.connected == true {
            interactor.requestStart()
        } else {
            interactor.requestPermissions()
        }
    }
    
    func stopFacebook() {
        guard let fbStatus = facebookStatus else { return }
        if fbStatus.connected == true {
            interactor.requestStop()
        }
    }
}

// MARK: - ImportFromFBInteractorOutput
extension ImportFromFBPresenter: ImportFromFBInteractorOutput {
    
    // MARK: Status
    
    func statusSuccessCallback(status: FBStatusObject) {
        facebookStatus = status
        if status.connected == true, status.syncEnabled == true {
            view?.succeedFacebookStart()
            analyticsService.track(event: .importFacebook)
            interactor.trackImportActivationFB()
        } else {
            view?.succeedFacebookStop()
        }
        view?.stopActivityIndicator()
    }
    
    func statusFailureCallback(errorMessage: String) {
        view?.failedFacebookStatus(errorMessage: errorMessage)
        view?.stopActivityIndicator()
    }
    
    // MARK: Start
    
    func startSuccessCallback() {
        view?.succeedFacebookStart()
        interactor.trackImportActivationFB()
        analyticsService.track(event: .importFacebook)
    }
    
    func startFailureCallback(errorMessage: String) {
        view?.failedFacebookStart(errorMessage: errorMessage)
        interactor.requestStatus()
    }
    
    // MARK: Stop
    
    func stopSuccessCallback() {
        view?.succeedFacebookStop()
    }
    
    func stopFailureCallback(errorMessage: String) {
        view?.failedFacebookStop(errorMessage: errorMessage)
        interactor.requestStatus()
    }
    
    // MARK: Permissions
    
    func permissionsSuccessCallback(permissions: FBPermissionsObject) {
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
    
    func permissionsFailureCallback(errorMessage: String) {
        view?.failedFacebookStart(errorMessage: errorMessage)
        interactor.requestStatus()
    }
    
    // MARK: Token
    
    func tokenSuccessCallback(token: String) {
        interactor.requestConnect(withToken: token)
    }
    
    func tokenFailureCallback(errorMessage: String) {
        if errorMessage != TextConstants.NotLocalized.facebookLoginCanceled {
            view?.failedFacebookStart(errorMessage: errorMessage)
        }
        interactor.requestStatus()
    }
    
    // MARK: Connect
    
    func connectSuccessCallback() {
        interactor.requestStart()
        interactor.requestStatus()
    }
    
    func connectFailureCallback(errorMessage: String) {
        view?.failedFacebookStart(errorMessage: errorMessage)
    }
    
    // MARK: Router
    
    func goToOnboarding() {
        router.goToOnboarding()
    }
}
