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
    case success(accessToken: String, refreshToken: String)
    /// Authorization flow was manually canceled by user!
    case cancel
    /// some error from sdk
    case failed(String)
}
typealias DropboxLoginHandler = (DropboxManagerResult) -> Void

final class DropboxManager {
    
    func start() {
        #if LIFEBOX
        DropboxClientsManager.setupWithAppKey("ld8xzj3w9fsnvxd")
        #else
        DropboxClientsManager.setupWithAppKey("ld8xzj3w9fsnvxd")
        #endif
    }
    
    func handleRedirect(url: URL) -> Bool {
        debugLog("DropboxManager handleRedirect")
        
        return DropboxClientsManager.handleRedirectURL(url) { [weak self] authResult in
            self?.handle(result: authResult)
        }
    }
    
    private func handle(result: DropboxOAuthResult?) {
        guard let result = result else {
            return
        }
        
        switch result {
        case .success(let token):
            handler?(.success(accessToken: token.accessToken, refreshToken: token.refreshToken ?? ""))
            debugLog("DropboxManager User is logged into Dropbox.")
        case .cancel:
            handler?(.cancel)
            debugLog("DropboxManager Authorization flow was manually canceled by user!")
        case .error(_, let description):
            let description = description ?? ""
            handler?(.failed(description))
            debugLog("DropboxManager Error: \(description)")
            print("Error: \(description)")
        }
    }
    
    private var handler: DropboxLoginHandler?
    
    private var accessToken: String? {
        return DropboxOAuthManager.sharedOAuthManager.getFirstAccessToken()?.accessToken
    }

    private var refreshToken: String? {
        return DropboxOAuthManager.sharedOAuthManager.getFirstAccessToken()?.refreshToken
    }
    
    func loginIfNeed(handler: @escaping DropboxLoginHandler) {
        debugLog("DropboxManager login")
        if let token = accessToken, let refreshToken = refreshToken {
            handler(.success(accessToken: token, refreshToken: refreshToken))
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
        
        let scopeRequest = ScopeRequest(scopeType: .user, scopes: [], includeGrantedScopes: false)
        DropboxClientsManager.authorizeFromControllerV2(
            UIApplication.shared,
            controller: vc,
            loadingStatusDelegate: nil,
            openURL: { (url: URL) -> Void in UIApplication.shared.open(url, options: [:], completionHandler: nil) },
            scopeRequest: scopeRequest
        )
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
    
    func requestConnect(withToken accessToken: String, refreshToken: String, success: SuccessResponse?, fail: FailResponse?) {
        debugLog("DropboxService requestConnect")

        let dropbox = DropboxConnect(withToken: accessToken, refreshToken: refreshToken)
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
