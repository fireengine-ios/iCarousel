//
//  ImportPhotosInteractorOutput.swift
//  Depo
//
//  Created by Maksim Rahleev on 04.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

// MARK: - Facebook

protocol ImportFromFBInteractorOutput: class {
    
    func connectionSuccess(isConnected: Bool)
    func connectionFailure(errorMessage: String)
    
    func disconnectionSuccess()
    func disconnectionFailure(errorMessage: String)
    
    func connectionWithTokenSuccess()
    func connectionWithTokenFailure(errorMessage: String)
    
    func syncStatusSuccess(status: Bool)
    func syncStatusFailure(errorMessage: String)
    
    func startImportSuccess()
    func startImportFailure(errorMessage: String)
    
    func stopImportSuccess()
    func stopImportFailure(errorMessage: String)
    
    func permissionsSuccess(permissions: FBPermissionsObject)
    func permissionsFailure(errorMessage: String)
    
    func tokenSuccess(token: String)
    func tokenFailure(errorMessage: String)
}

// MARK: - Dropbox

protocol ImportFromDropboxInteractorOutput: class {
    
    func loginSuccessCallback(token: String)
    func loginFailureCallback(errorMessage: String)
    func loginCanceled()
    
    func connectSuccessCallback()
    func connectFailureCallback(errorMessage: String)

    func statusSuccessCallback(status: DropboxStatusObject)
    func statusFailureCallback(errorMessage: String)
    
    func statusForStartSuccessCallback(status: DropboxStatusObject)
    func statusForStartFailureCallback(errorMessage: String)
    
    func startSuccessCallback()
    func startFailureCallback(errorMessage: String)
    
    func failedWithInternetError(errorMessage: String)
    
    func statusForCompletionSuccessCallback(dropboxStatus: DropboxStatusObject)
    func statusForCompletionFailureCallback(errorMessage: String)
}

// MARK: - Instagram

protocol ImportFromInstagramInteractorOutput: class {
    
    func connectionSuccess(isConnected: Bool, username: String?)
    func connectionFailure(errorMessage: String)
    
    func disconnectionSuccess()
    func disconnectionFailure(errorMessage: String)
    
    func instaPickSuccess(isOn: Bool)
    func instaPickFailure(errorMessage: String)
    
    func syncStatusSuccess(status: Bool)
    func syncStatusFailure(errorMessage: String)

    func configSuccess(instagramConfig: InstagramConfigResponse)
    func configFailure(errorMessage: String)
    
    func startSyncSuccess()
    func startSyncFailure(errorMessage: String)
    
    func stopSyncSuccess()
    func stopSyncFailure(errorMessage: String)
    
    func uploadCurrentSuccess()
    func uploadCurrentFailure(errorMessage: String)

    func cancelUploadSuccess()
    func cancelUploadFailure(errorMessage: String)
}
