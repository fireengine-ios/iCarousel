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
    func startFacebook()
    func stopFacebook()
}

// MARK: - Dropbox

protocol ImportFromDropboxViewOutput {
    func viewIsReady()
    func startDropbox()
}

protocol ImportFromInstagramViewOutput {
    
}
