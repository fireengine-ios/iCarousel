//
//  ImportPhotosInteractorInput.swift
//  Depo
//
//  Created by Maksim Rahleev on 04.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

// MARK: - Facebook

protocol ImportFromFBInteractorInput {
    
    func getAllStatuses()
    func disconnectAccount()
    func setImport(status: Bool)
    
    func requestPermissions()
    func requestToken(permissions: [String])
    func connect(withToken token: String)
    func requestSyncStatus()
    func trackConnectionStatusFB(isConnected: Bool)
    func trackImportStatusFB(isOn: Bool)
}

// MARK: - Dropbox

protocol ImportFromDropboxInteractorInput {
    func disconnectAccount()
    func startImport()
    func getAllStatuses()

    func login()
    func requestStatusForStart()
    func connect(withToken token: String)
    func requestStart()
    func requestStatusForCompletion()
    func trackConnectionStatusDropBox(isConnected: Bool)
    func trackImportStatusDropBox(isOn: Bool)
}

// MARK: - Instagram

protocol ImportFromInstagramInteractorInput {
    func getAllStatuses()
    func disconnectAccount()
    func setInstaPick(status: Bool)
    func setSync(status: Bool)
    func trackConnectionStatusInstagram(isConnected: Bool)
    func trackImportStatusInstagram(isOn: Bool)
}
