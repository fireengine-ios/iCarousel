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
    
//    func requestToken(withCurrentToken currentToken: String, withConsumerKey consumerKey: String, withAppSecret appSecret: String, withAuthTokenSecret authTokenSecret: String)
//
//    func requestConnect(withToken token: String)
//
//    func requestStatusForStart()
//
//    func requestStatus()
//
//    func requestStart()
//
//    func onLogout()
}
