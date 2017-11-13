//
//  DropboxService.swift
//  Depo
//
//  Created by Максим Деханов on 04.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import ObjectiveDropboxOfficial

enum DropboxManagerResult {
    case success(String)
    case cancel
    case failed(String)
}
typealias DropboxLoginHandler = (DropboxManagerResult) -> Void

final class DropboxManager {
    
    func start() {
        DBClientsManager.setup(withAppKey: "422fptod5dlxrn8")
    }
    
    func handleRedirect(url: URL) -> Bool {
        guard let dbResult = DBClientsManager.handleRedirectURL(url) else {
            return false
        }
        
        print(dbResult)
        if dbResult.isSuccess() {
            handler?(.success(dbResult.accessToken.accessToken))
            print("Success! User is logged into Dropbox.")
        } else if dbResult.isCancel() {
            handler?(.cancel)
            print("Authorization flow was manually canceled by user!")
        } else if dbResult.isError() {
            handler?(.failed(dbResult.description()))
            print("Error: \(dbResult)")
        }
        
        return true
    }
    
    var handler: DropboxLoginHandler?
    
    func login(handler: @escaping DropboxLoginHandler) {
        if let token = DBOAuthManager.shared()?.retrieveFirstAccessToken()?.accessToken {
            handler(.success(token))
            return
        }
        self.handler = handler
        guard let vc = (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController else {
            return
        }
        DBClientsManager.authorize(fromController: UIApplication.shared, controller: vc) { url in
            UIApplication.shared.openURL(url)
        }
    }
    
    func logout() {
        DBOAuthManager.shared()?.clearStoredAccessTokens()
    }
}

class DropboxService: BaseRequestService {
    
    func requestToken(withCurrentToken currentToken: String, withConsumerKey consumerKey: String, withAppSecret appSecret: String, withAuthTokenSecret authTokenSecret: String, success: SuccessResponse?, fail: FailResponse?) {
        let dropbox = DropboxAuth(withCurrentToken: currentToken, withConsumerKey: consumerKey, withAppSecret: appSecret, withAuthTokenSecret: authTokenSecret)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: dropbox, handler: handler)
    }
    
    func requestConnect(withToken token: String, success: SuccessResponse?, fail: FailResponse?) {
        let dropbox = DropboxConnect(withToken: token)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: dropbox, handler: handler)
    }
    
    func requestStatus(success: SuccessResponse?, fail: FailResponse?) {
        let dropbox = DropboxStatus()
        let handler = BaseResponseHandler<DropboxStatusObject, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: dropbox, handler: handler)
    }
    
    func requestStart(success: SuccessResponse?, fail: FailResponse?) {
        let dropbox = DropboxStart()
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: dropbox, handler: handler)

    }
}
