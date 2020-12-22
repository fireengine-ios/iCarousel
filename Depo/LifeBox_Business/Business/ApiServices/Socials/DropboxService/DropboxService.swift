//
//  DropboxService.swift
//  Depo
//
//  Created by Максим Деханов on 04.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
//import ObjectiveDropboxOfficial
import Alamofire
import SwiftyDropbox

enum DropboxManagerResult {
    /// User is logged into Dropbox
    case success(token: String)
    /// Authorization flow was manually canceled by user!
    case cancel
    /// some error from sdk
    case failed(String)
}
typealias DropboxLoginHandler = (DropboxManagerResult) -> Void

final class DropboxManager {
    
    func start() {
        #if LIFEBOX
        DropboxClientsManager.setupWithAppKey("422fptod5dlxrn8")
        #else
        DropboxClientsManager.setupWithAppKey("mij832wzxlbyeiq")
        #endif
    }
    
    func handleRedirect(url: URL) -> Bool {
        debugLog("DropboxManager handleRedirect")
        
        guard let authResult = DropboxClientsManager.handleRedirectURL(url) else {
            return false
        }
        
        switch authResult {
        case .success(let accessToken):
            handler?(.success(token: accessToken.accessToken))
            debugLog("DropboxManager User is logged into Dropbox.")
        case .cancel:
            handler?(.cancel)
            debugLog("DropboxManager Authorization flow was manually canceled by user!")
        case .error(_, let description):
            handler?(.failed(description))
            debugLog("DropboxManager Error: \(description)")
            print("Error: \(description)")
        }
        
        return true
    }
    
    private var handler: DropboxLoginHandler?
    
    private var token: String? {
        return DropboxOAuthManager.sharedOAuthManager.getFirstAccessToken()?.accessToken
    }
    
    func loginIfNeed(handler: @escaping DropboxLoginHandler) {
        debugLog("DropboxManager login")
        if let token = token {
            handler(.success(token: token))
            return
        }
        login(handler: handler)
    }
    
    func login(handler: @escaping DropboxLoginHandler) {
        debugLog("DropboxManager login")
        
        self.handler = handler
        guard let vc = (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController else {
            return
        }
        
        DropboxClientsManager.authorizeFromController(UIApplication.shared, controller: vc) { url in
            UIApplication.shared.openURL(url)
        }
    }
    
    func logout() {
        debugLog("DropboxManager logout")
        _ = DropboxOAuthManager.sharedOAuthManager.clearStoredAccessTokens()
    }
}

class DropboxService: BaseRequestService {
    
    private lazy var sessionManager: SessionManager = factory.resolve()
    
    func disconnectDropbox(handler: @escaping (ResponseResult<Void>) -> Void) {
        sessionManager
            .request(RouteRequests.dropboxDisconnect,
                     method: .get)
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(_):
                    handler(.success(()))
                case .failure(let error):
                    handler(.failed(error))
                }
        }
    }
    
    func requestToken(withCurrentToken currentToken: String, withConsumerKey consumerKey: String, withAppSecret appSecret: String, withAuthTokenSecret authTokenSecret: String, success: SuccessResponse?, fail: FailResponse?) {
        debugLog("DropboxService requestToken")

        let dropbox = DropboxAuth(withCurrentToken: currentToken, withConsumerKey: consumerKey, withAppSecret: appSecret, withAuthTokenSecret: authTokenSecret)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: dropbox, handler: handler)
    }
    
    func requestConnect(withToken token: String, success: SuccessResponse?, fail: FailResponse?) {
        debugLog("DropboxService requestConnect")

        let dropbox = DropboxConnect(withToken: token)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: dropbox, handler: handler)
    }
    
    func requestStatus(success: SuccessResponse?, fail: FailResponse?) {
        debugLog("DropboxService requestStatus")

        let dropbox = DropboxStatus()
        let handler = BaseResponseHandler<DropboxStatusObject, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: dropbox, handler: handler)
    }
    
    func requestStart(success: SuccessResponse?, fail: FailResponse?) {
        debugLog("DropboxService requestStart")

        let dropbox = DropboxStart()
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: dropbox, handler: handler)

    }
}
