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
    
    func onLogout()
}

// MARK: - Dropbox

protocol ImportFromDropboxInteractorInput {
    
    func requestToken(withCurrentToken currentToken: String, withConsumerKey consumerKey: String, withAppSecret appSecret: String, withAuthTokenSecret authTokenSecret: String)
    
    func requestConnect(withToken token: String)
    
    func requestStatusForStart()
    
    func requestStatus()
    
    func requestStart()
    
    func onLogout()
}
