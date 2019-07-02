//
//  AuthorizationRepository.swift
//  LifeBox-new
//
//  Created by Bondar Yaroslav on 10/10/2017.
//  Copyright © 2017 Bondar Yaroslav. All rights reserved.
//

import Alamofire

typealias RefreshCompletion = (_ succeeded: Bool, _ accessToken: String?, _ error: Error?) -> Void

// TODO: Need to test refresh token request for no internet connection and timed out

protocol AuthorizationRepository: RequestAdapter, RequestRetrier {
    var refreshFailedHandler: VoidHandler { get set }
    func refreshTokens(completion: @escaping RefreshCompletion)
}

/// https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#adapting-and-retrying-requests
open class AuthorizationRepositoryImp: AuthorizationRepository {
    
    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        return SessionManager(configuration: configuration)
    }()
    
    private let lock = NSLock()
    
    private var urls: AuthorizationURLs
    private var tokenStorage: TokenStorage
    
    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    let uuid = "uuid"
    let name = "name"
    let deviceType = "deviceType"
    
    // MARK: - Open properties for customization (by override)
    
    open var accessTokenKey: String {
        return HeaderConstant.AuthToken
    }
    open var refreshTokenKey: String {
        return HeaderConstant.RememberMeToken
    }
    open var authorizationHeaderKey: String {
        return HeaderConstant.AuthToken
    }
    open func fullAccessToken(_ accessToken: String) -> String {
        return accessToken
    }
    
    /// will be executed if refresh token is invalid (statusCode == 401 for urls.refreshAccessToken)
    open var refreshFailedHandler: VoidHandler = {}
    
    // MARK: - Init
    
    init(urls: AuthorizationURLs, tokenStorage: TokenStorage) {
        self.urls = urls
        self.tokenStorage = tokenStorage
    }
    
    private var refreshAttempts = 0
    private var maxRefreshAttempts = 3
    private var refreshTokensCompletions = [RefreshCompletion]()
}

extension AuthorizationRepositoryImp: RequestAdapter {
    
    public func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        guard urlRequest.url?.absoluteString != nil,
            let accessToken = tokenStorage.savedAccessToken
            else { return urlRequest }
        var urlRequest = urlRequest
        urlRequest.setValue(fullAccessToken(accessToken), forHTTPHeaderField: authorizationHeaderKey)
        return urlRequest
    }
}

extension AuthorizationRepositoryImp: RequestRetrier {
    
    public func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock() ; defer { lock.unlock() }
        
        guard let response = request.task?.response as? HTTPURLResponse else {
            completion(false, 0.0)
            return
        }

        /// maybe will be need
//        if tokenStorage.refreshToken == nil, request.request?.url?.absoluteString.contains("account/info") == true {
//            completion(false, 0.0)
//            return
//        }
        
        /// if accessToken is valid
        guard response.statusCode == 401 else {
            completion(false, 0.0)
            return
        }
        
        #if MAIN_APP
        if let url = request.request?.url?.absoluteString {
            debugLog("401 for an URL that is hidden because of the safety requirements")
        } else {
            debugLog("request.request?.url?.absoluteString is nil")
        }
        debugLog(request.description)
        #endif
        
        /// save request
        requestsToRetry.append(completion)
        
        /// guard refresh retry
        if isRefreshing {
            return
        }
        
        refreshTokens { [weak self] succeeded, accessToken, _  in
            guard let strongSelf = self else { return }
            strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }
            
            /// save accessToken to storage
            if let accessToken = accessToken {
                strongSelf.tokenStorage.accessToken = accessToken
            }
            
            /// retry all saved requests
            strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
            strongSelf.requestsToRetry.removeAll()
        }
    }
    
    
    // MARK: - Refresh Tokens
    
    func refreshTokens(completion: @escaping RefreshCompletion) {
        /// guard refresh retry
        if isRefreshing {
            refreshTokensCompletions.append(completion)
            return
        }
        
        /// start refresh status
        isRefreshing = true
        
        
        /// send request with refreshToken to get new accessToken
        
        let headers = [refreshTokenKey: tokenStorage.refreshToken ?? ""]
        
        sessionManager
            .request(urls.refreshAccessToken, method: .post, parameters: Device.deviceInfo,
                     encoding: JSONEncoding.default, headers: headers)
            .responseJSON { [weak self] response in
                guard let strongSelf = self else {
                    /// must execute never
                    completion(false, nil, nil)
                    self?.isRefreshing = false
                    self?.refreshTokensCompletions.forEach { $0(false, nil, nil) }
                    self?.refreshTokensCompletions.removeAll()
                    return
                }
                
                debugPrint(response)
                /// if tokenStorage.refreshToken is invalid
                if response.response?.statusCode == 401 {
                    #if MAIN_APP
                    debugLog("failed refreshAccessToken")
                    #endif
                    strongSelf.refreshFailedHandler()
                    completion(false, nil, nil)
                    strongSelf.isRefreshing = false
                    strongSelf.refreshTokensCompletions.forEach { $0(false, nil, nil) }
                    strongSelf.refreshTokensCompletions.removeAll()
                
                /// mapping accessToken for completion handler
                } else if let headers = response.response?.allHeaderFields as? [String: Any],
                    let accessToken = headers[strongSelf.accessTokenKey] as? String {
                    completion(true, accessToken, nil)
                    strongSelf.isRefreshing = false
                    strongSelf.refreshTokensCompletions.forEach { $0(true, accessToken, nil) }
                    strongSelf.refreshTokensCompletions.removeAll()
                    
                /// retry refreshTokens request only for bad internet
                } else if strongSelf.refreshAttempts < strongSelf.maxRefreshAttempts {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) { 
                        strongSelf.refreshAttempts += 1
                        strongSelf.isRefreshing = false
                        strongSelf.refreshTokens(completion: completion)
                    }
//                    return
                } else {
                    #if MAIN_APP
                    debugLog("can't take accessToken refreshAccessToken")
                    #endif
                    completion(false, nil, response.error)
                    strongSelf.isRefreshing = false
                    strongSelf.refreshTokensCompletions.forEach { $0(false, nil, nil) }
                    strongSelf.refreshTokensCompletions.removeAll()
                }
                
                /// end refresh status
//                strongSelf.isRefreshing = false
        }
    }
}
