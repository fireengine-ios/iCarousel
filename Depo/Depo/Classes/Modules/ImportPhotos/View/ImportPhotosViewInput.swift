//
//  ImportPhotosViewInput.swift
//  Depo
//
//  Created by Maksim Rahleev on 04.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

// MARK: - Facebook

protocol ImportFromFBViewInput: class {
    
    // MARK: - Permissions
    func fbPermissionsSuccessCallback(permissions: FBPermissionsObject)
    func fbPermissionsFailureCallback(errorMessage: String)
    
    // MARK: - Token
    func fbTokenSuccessCallback(token: String)
    func fbTokenFailureCallback(errorMessage: String)
    
    // MARK: - Connect to FB with token
    func fbConnectSuccessCallback()
    func fbConnectFailureCallback(errorMessage: String)
    
    // MARK: - Status of sync with FB
    func fbStatusSuccessCallback(status: FBStatusObject)
    func fbStatusFailureCallback(errorMessage: String)
    
    // MARK: - Start to sync with FB
    func fbStartSuccessCallback()
    func fbStartFailureCallback(errorMessage: String)
    
    // MARK: - Stop to sync with FB
    func fbStopSuccessCallback()
    func fbStopFailureCallback(errorMessage: String)
}

// MARK: - Dropbox

protocol ImportFromDropboxViewInput: class {
    // MARK: - Token
    func dbTokenSuccessCallback(token: String)
    func dbTokenFailureCallback(errorMassage: String)
    
    // MARK: - Connect to DB with token
    func dbConnectSuccessCallback()
    func dbConnectFailureCallback(errorMassage: String)
    
    // MARK: - Status of DB for start
    func dbStatusForStartSuccessCallback(status: DropboxStatusObject)
    func dbStatusForStartFaillureCallback(errorMessage: String)
    
    // MARK: - Start to sync with DB
    func dbStartSuccessCallback()
    func dbStartFailureCallback(errorMessage: String)
    
    // MARK: - Status of sync with DB
    func dbStatusSuccessCallback(status: DropboxStatusObject)
    func dbStatusFailureCallback(errorMessage: String)
}
