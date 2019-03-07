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
    
    func loginSuccess(token: String)
    func loginFailure(errorMessage: String)
    func loginCanceled()
    
    func connectWithTokenSuccess()
    func connectWithTokenFailure(errorMessage: String)
    
    func disconnectionSuccess()
    func disconnectionFailure(errorMessage: String)

    func statusSuccess(status: DropboxStatusObject)
    func statusFailure(errorMessage: String)
    
    func statusForStartSuccess(status: DropboxStatusObject)
    func statusForStartFailure(errorMessage: String)
    
    func startSuccess()
    func startFailure(errorMessage: String)
    
    func failedWithInternetError(errorMessage: String)
    
    func statusForCompletionSuccess(dropboxStatus: DropboxStatusObject)
    func statusForCompletionFailure(errorMessage: String)
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
