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
    func connectionStatusSuccess(_ isOn: Bool)
    func connectionStatusFailure(errorMessage: String)
    
    func syncStatusSuccess(_ isOn: Bool)
    func syncStatusFailure()
    
    func importStartSuccess()
    func importStartFailure(errorMessage: String)
    
    func importStopSuccess()
    func importStopFailure(errorMessage: String)
    
    func disconnectionSuccess()
    func disconnectionFailure(errorMessage: String)
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
    
    func connectionStatusSuccess(_ isOn: Bool, username: String?)
    func connectionStatusFailure(errorMessage: String)
    
    func instaPickStatusSuccess(_ isOn: Bool)
    func instaPickStatusFailure()
    
    func syncStatusSuccess(_ isOn: Bool)
    func syncStatusFailure()
    
    func syncStartSuccess()
    func syncStartFailure(errorMessage: String)
    
    func syncStopSuccess()
    func syncStopFailure(errorMessage: String)
    
    func disconnectionSuccess()
    func disconnectionFailure(errorMessage: String)
}
