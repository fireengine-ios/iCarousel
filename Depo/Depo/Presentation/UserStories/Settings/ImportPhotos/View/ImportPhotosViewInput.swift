//
//  ImportPhotosViewInput.swift
//  Depo
//
//  Created by Maksim Rahleev on 04.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

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
    func dbStartSuccessCallback()
    func failedDropboxStart(errorMessage: String)
    
    func startDropboxStatus()
    func updateDropboxStatus(progressPercent: Int)
    func stopDropboxStatus(lastUpdateMessage: String)
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
