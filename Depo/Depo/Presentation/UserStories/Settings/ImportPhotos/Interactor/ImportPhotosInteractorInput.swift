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
    func trackImportActivationFB()
}

// MARK: - Dropbox

protocol ImportFromDropboxInteractorInput {
    func requestStatus()
    func requestStatusForStart()
    func login()
    func requestConnect(withToken token: String)
    func requestStart()
    func requestStatusForCompletion()
    func trackImportActivationDropBox()
}

// MARK: - Instagram

protocol ImportFromInstagramInteractorInput {
    func getAllStatuses()
    func disconnectAccount()
    func setInstaPick(status: Bool)
    func setSync(status: Bool)
    func trackImportActivationInstagram()
}
