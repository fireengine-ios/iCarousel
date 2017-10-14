//
//  ImportPhotosPresenter.swift
//  Depo
//
//  Created by Maksim Rahleev on 04.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

// MARK: - Facebook

class ImportFromFBPresenter: BasePresenter, ImportFromFBViewOutput, ImportFromFBInteractorOutput {
    weak var view: ImportFromFBViewInput!
    var interactor: ImportFromFBInteractorInput!
    var router: ImportFromFBRouterInput!
    
    func onLogout() {
        startAsyncOperation()
        interactor.onLogout()
    }
    
    // Permissions for FB
    
    func requestPermissions() {
        interactor.requestPermissions()
    }
    
    func permissionsSuccessCallback(permissions: FBPermissionsObject) {
        view.fbPermissionsSuccessCallback(permissions: permissions)
    }
    
    func permissionsFailureCallback(errorMessage: String) {
        view.fbPermissionsFailureCallback(errorMessage: errorMessage)
    }
    
    // MARK: - Token For FB
    
    func requestToken(permissions: [String]) {
        interactor.requestToken(permissions: permissions)
    }
    
    func tokenSuccessCallback(token: String) {
        view.fbTokenSuccessCallback(token: token)
    }
    
    func tokenFailureCallback(errorMessage: String) {
        view.fbTokenFailureCallback(errorMessage: errorMessage)
    }
    
    // MARK: - Connect to FB with token
    
    func requestConnect(withToken token: String) {
        interactor.requestConnect(withToken: token)
    }
    
    func connectSuccessCallback() {
        view.fbConnectSuccessCallback()
    }
    
    func connectFailureCallback(errorMessage: String) {
        view.fbConnectFailureCallback(errorMessage: errorMessage)
    }
    
    // MARK: - Get Status of sync with FB
    
    func requestStatus() {
        interactor.requestStatus()
    }
    
    func statusSuccessCallback(status: FBStatusObject) {
        view.fbStatusSuccessCallback(status: status)
    }
    
    func statusFailureCallback(errorMessage: String) {
        view.fbStatusFailureCallback(errorMessage: errorMessage)
    }
    
    // MARK: - Start to sync with FB
    
    func requestStart() {
        interactor.requestStart()
    }
    
    func startSuccessCallback() {
        view.fbStartSuccessCallback()
    }
    
    func startFailureCallback(errorMessage: String) {
        view.fbStartFailureCallback(errorMessage: errorMessage)
    }
    
    // MARK: - Stop to sync with FB
    
    func requestStop() {
        interactor.requestStop()
    }
    
    func stopSuccessCallback() {
        view.fbStopSuccessCallback()
    }
    
    func stopFailureCallback(errorMessage: String) {
        view.fbStopFailureCallback(errorMessage: errorMessage)
    }
    
    // MARK: -
    
    func goToOnboarding() {
        router.goToOnboarding()
    }
}

// MARK: - Dropbox

class ImportFromDropboxPresenter: BasePresenter, ImportFromDropboxViewOutput, ImportFromDropboxInteractorOutput {
    
    weak var view: ImportFromDropboxViewInput!
    var interactor: ImportFromDropboxInteractorInput!
    var router: ImportFromDropboxRouterInput!
    
    func onLogout() {
        startAsyncOperation()
        interactor.onLogout()
    }
    
    // MARK: - Token For DB
    
    func requestToken(withCurrentToken currentToken: String, withConsumerKey consumerKey: String, withAppSecret appSecret: String, withAuthTokenSecret authTokenSecret: String) {
        interactor.requestToken(withCurrentToken: currentToken, withConsumerKey: consumerKey, withAppSecret: appSecret, withAuthTokenSecret: authTokenSecret)
    }
    func tokenSuccessCallback(token: String) {
        if let _ = view {
            view.dbTokenSuccessCallback(token: token)
        }
    }
    
    func tokenFailureCallback(errorMessage: String) {
        view.dbTokenFailureCallback(errorMassage: errorMessage)
    }
    
    // MARK: - Connect to DB with token
    
    func requestConnect(withToken token: String) {
        interactor.requestConnect(withToken: token)
    }
    
    func connectSuccessCallback() {
        if let _ = view {
            view.dbConnectSuccessCallback()
        }
    }
    
    func connectFailureCallback(errorMessage: String) {
        view.dbConnectFailureCallback(errorMassage: errorMessage)
    }
    
    // MARK: - Get status of DB for start
    
    func requestStatusForStart() {
        interactor.requestStatusForStart()
    }
    
    func statusForStartSuccessCallback(status: DropboxStatusObject) {
        if let _ = view {
            view.dbStatusForStartSuccessCallback(status: status)
        }
    }
    
    func statusForStartFailureCallback(errorMessage: String) {
        view.dbStatusForStartFaillureCallback(errorMessage: errorMessage)
    }
    
    // MARK: - Start to sync with DB
    
    func requestStart() {
        interactor.requestStart()
    }
    
    func startSuccessCallback() {
        if let _ = view {
            view.dbStartSuccessCallback()
        }
    }
    
    func startFailureCallback(errorMessage: String) {
        view.dbStartFailureCallback(errorMessage: errorMessage)
    }
    
    // MARK: - Get Status of sync with DB
    
    func requestStatus() {
        interactor.requestStatus()
    }
    
    func statusSuccessCallback(status: DropboxStatusObject) {
        if let _ = view {
            view.dbStatusSuccessCallback(status: status)
        }
    }
    
    func statusFailureCallback(errorMessage: String) {
        view.dbStatusFailureCallback(errorMessage: errorMessage)
    }
    
    func goToOnboarding() {
        router.goToOnboarding()
    }
}
