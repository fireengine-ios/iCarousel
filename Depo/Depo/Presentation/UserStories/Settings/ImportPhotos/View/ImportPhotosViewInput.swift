//
//  ImportPhotosViewInput.swift
//  Depo
//
//  Created by Maksim Rahleev on 04.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

protocol ActivityIndicator {
    func startActivityIndicator()
    func stopActivityIndicator()
}

// MARK: - Facebook

protocol ImportFromFBViewInput: class, ActivityIndicator {
    
    func succeedFacebookStart()
    func failedFacebookStart(errorMessage: String)
    
    func succeedFacebookStop()
    func failedFacebookStop(errorMessage: String)
    
    func failedFacebookStatus(errorMessage: String)
}

// MARK: - Dropbox

protocol ImportFromDropboxViewInput: class, ActivityIndicator {
    
    func dbStatusSuccessCallback(status: DropboxStatusObject)
    func dbStatusFailureCallback()
    
    func dbStartSuccessCallback()
    func failedDropboxStart(errorMessage: String)
}

// MARK: - Instagram

protocol ImportFromInstagramViewInput: class, ActivityIndicator {
    func instagramStatusSuccess()
    func instagramStatusFailure()
    
    func instagramStartSuccess()
    func instagramStartFailure(errorMessage: String)
    
    func instagramStopSuccess()
    func instagramStopFailure(errorMessage: String)
}
