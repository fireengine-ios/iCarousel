//
//  DropboxParametrs.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/8/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

class DropboxAuth: BaseRequestParametrs {
    private let consumerKey: String
    private let currentToken: String
    private let appSecret: String
    private let authTokenSecret: String
    
    override var patch: URL {
        return RouteRequests.dropboxAuthUrl
    }
    
    override var header: RequestHeaderParametrs {
        let param = String(format: "OAuth oauth_version=\"1.0\", oauth_signature_method=\"PLAINTEXT\", oauth_consumer_key=\"%@\", oauth_token=\"%@\", oauth_signature=\"%@&%@\"", consumerKey, currentToken, appSecret, authTokenSecret)
        return [HeaderConstant.Authorization :param]
    }
    
    init(withCurrentToken currentToken: String, withConsumerKey consumerKey: String, withAppSecret appSecret: String, withAuthTokenSecret authTokenSecret: String) {
        self.consumerKey = consumerKey
        self.currentToken = currentToken
        self.appSecret = appSecret
        self.authTokenSecret = authTokenSecret
    }
}

class DropboxConnect: BaseRequestParametrs {
    private let token: String
    
    override var patch: URL {
        let patch_ = String(format: RouteRequests.dropboxConnect, token)
        return  URL(string: patch_, relativeTo: RouteRequests.baseUrl)!
    }
    
    init(withToken token: String) {
        self.token = token
    }
}

class DropboxStatus: BaseRequestParametrs {
    
    override var patch: URL {
        return URL(string: RouteRequests.dropboxStatus, relativeTo: super.patch)!
    }
}

class DropboxStart: BaseRequestParametrs {
    
    override var patch: URL {
        return URL(string: RouteRequests.dropboxStart, relativeTo: super.patch)!
    }
}
