//
//  ImportPhotosInteractorOutput.swift
//  Depo
//
//  Created by Maksim Rahleev on 04.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

// MARK: - Facebook

protocol ImportFromFBInteractorOutput {

    func permissionsSuccessCallback(permissions: FBPermissionsObject)
    func permissionsFailureCallback(errorMessage: String)

    func tokenSuccessCallback(token: String)
    func tokenFailureCallback(errorMessage: String)
    
    func connectSuccessCallback()
    func connectFailureCallback(errorMessage: String)
    
    func statusSuccessCallback(status: FBStatusObject)
    func statusFailureCallback(errorMessage: String)
    
    func startSuccessCallback()
    func startFailureCallback(errorMessage: String)
    
    func stopSuccessCallback()
    func stopFailureCallback(errorMessage: String)
    
    func goToOnboarding()
    
//    func success(socialStatus: SocialStatusResponse)
//    func failed(with errorMessage: String)
}

// MARK: - Dropbox

protocol ImportFromDropboxInteractorOutput {
    
    func loginSuccessCallback(token: String)
    func loginFailureCallback(errorMessage: String)
    
    func connectSuccessCallback()
    func connectFailureCallback(errorMessage: String)

    func statusSuccessCallback(status: DropboxStatusObject)
    func statusFailureCallback(errorMessage: String)
    
    func statusForStartSuccessCallback(status: DropboxStatusObject)
    func statusForStartFailureCallback(errorMessage: String)
    
    func startSuccessCallback()
    func startFailureCallback(errorMessage: String)
    
//    func statusSuccessCallback(status: DropboxStatusObject)
//    func statusFailureCallback(errorMessage: String)
//    
//    func goToOnboarding()
}

// MARK: - Instagram

protocol ImportFromInstagramInteractorOutput {
    
}
