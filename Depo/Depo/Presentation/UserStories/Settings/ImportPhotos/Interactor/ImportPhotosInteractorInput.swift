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
    func requestPermissions()
    func requestToken(permissions: [String])
    func requestConnect(withToken token: String)
    func requestStatus()
    func requestStart()
    func requestStop()
}

// MARK: - Dropbox

protocol ImportFromDropboxInteractorInput {
    func requestStatus()
    func requestStatusForStart()
    func login()
    func requestConnect(withToken token: String)
    func requestStart()
    func requestStatusForCompletion()
}

// MARK: - Instagram

protocol ImportFromInstagramInteractorInput {
    func getConnectionStatus()
    func getConnection()
    func getConfig()
    func setAsync(status: Bool)
    func uploadCurrent()
    func cancelUpload()
}
