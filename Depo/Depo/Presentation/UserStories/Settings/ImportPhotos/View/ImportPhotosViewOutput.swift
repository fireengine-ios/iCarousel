//
//  ImportPhotosViewOutput.swift
//  Depo
//
//  Created by Maksim Rahleev on 04.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

// MARK: - Facebook

protocol ImportFromFBViewOutput {
    func viewIsReady()
    
    func disconnectAccount()
    
    func startImport()
    func stopImport()
}

// MARK: - Dropbox

protocol ImportFromDropboxViewOutput {
    func viewIsReady()
    
    func disconnectAccount()
    
    func startDropbox()
}

// MARK: - Instagram

protocol ImportFromInstagramViewOutput {
    func viewIsReady()
    
    func disconnectAccount()
    
    func startInstagram()
    func stopInstagram()
    
    func enableInstaPick()
    func disableInstaPick()
}
