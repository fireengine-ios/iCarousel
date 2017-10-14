//
//  ImportPhotosInteractor.swift
//  Depo
//
//  Created by Maksim Rahleev on 04.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

// MARK: - Facebook

class ImportFromFBInteractor: ImportFromFBInteractorInput {
    var output: ImportFromFBInteractorOutput!
    
    var dbService = FBService()
    
    // MARK: -
    
    func requestPermissions() {
        dbService.requestPermissions(success: { [unowned self] (responseObject) in
            let fbPermissions = responseObject as! FBPermissionsObject
            self.output.permissionsSuccessCallback(permissions: fbPermissions)
        }) { [unowned self] (error) in
            self.output.permissionsFailureCallback(errorMessage: error.description)
        }
    }
    
    func requestToken(permissions: [String]) {
        dbService.requestToken(permissions: permissions, success: { [unowned self] (token) in
            self.output.tokenSuccessCallback(token: token)
        }) { [unowned self] (error) in
            self.output.tokenFailureCallback(errorMessage: error.description)
        }
    }
    
    func requestConnect(withToken token: String) {
        dbService.requestConnect(withToken: token, success: { [unowned self] _ in
            self.output.connectSuccessCallback()
        }) { [unowned self] (error) in
            self.output.connectFailureCallback(errorMessage: error.description)
        }
    }
    
    func requestStatus() {
        dbService.requestStatus(success: { [unowned self] (responseObject) in
            let fbStatus = responseObject as! FBStatusObject
            self.output.statusSuccessCallback(status: fbStatus)
        }) { [unowned self] (error) in
            self.output.statusFailureCallback(errorMessage: error.description)
        }
    }
    
    func requestStart() {
        dbService.requestStart(success: { [unowned self] (_) in
            self.output.startSuccessCallback()
        }) { [unowned self] (error) in
            self.output.startFailureCallback(errorMessage: error.description)
        }
    }
    
    func requestStop() {
        dbService.requestStop(success: { [unowned self] (_) in
            self.output.stopSuccessCallback()
        }) { [unowned self] (error) in
            self.output.stopFailureCallback(errorMessage: error.description)
        }
    }
    
    func onLogout(){
        let authService = AuthenticationService()
        authService.logout {
            DispatchQueue.main.async { [unowned self] in
                self.output.goToOnboarding()
            }
        }
    }
}

// MARK: - Dropbox

class ImportFromDropboxInteractor: ImportFromDropboxInteractorInput {
    var output: ImportFromDropboxInteractorOutput!
    
    var dbService = DropboxService()
    
    // MARK: - 
    
    func requestToken(withCurrentToken currentToken: String, withConsumerKey consumerKey: String, withAppSecret appSecret: String, withAuthTokenSecret authTokenSecret: String) {
        
        dbService.requestToken(withCurrentToken: currentToken, withConsumerKey: consumerKey, withAppSecret: appSecret, withAuthTokenSecret: authTokenSecret, success: { (responseObject) in
            let response = responseObject as! ObjectRequestResponse
            self.output.tokenSuccessCallback(token: (response.json?["access_token"].stringValue)!)
        }) { (error) in
            self.output.tokenFailureCallback(errorMessage: error.description)
        }
    }
    
    func requestConnect(withToken token: String) {
        dbService.requestConnect(withToken: token, success: { _ in
            self.output.connectSuccessCallback()
        }) { (error) in
            self.output.connectFailureCallback(errorMessage: error.description)
        }
    }
    
    func requestStatusForStart() {
        dbService.requestStatus(success: { (responseObject) in
            let dropboxStatus = responseObject as! DropboxStatusObject
            self.output.statusForStartSuccessCallback(status: dropboxStatus)
        }) { (error) in
            self.output.statusForStartFailureCallback(errorMessage: error.description)
        }
    }
    
    func requestStatus() {
        
    }
    
    func requestStart() {
        dbService.requestStart(success: { (_) in
            self.output.startSuccessCallback()
        }) { (error) in
            self.output.startFailureCallback(errorMessage: error.description)
        }
    }
    
    func onLogout(){
        let authService = AuthenticationService()
        authService.logout {
            DispatchQueue.main.async {[weak self] in
                self?.output.goToOnboarding()
            }
        }
    }
}
