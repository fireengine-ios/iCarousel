//
//  AuthorizationManager.swift
//  LifeBox-new
//
//  Created by Bondar Yaroslav on 10/10/2017.
//  Copyright © 2017 Bondar Yaroslav. All rights reserved.
//

import Alamofire

// TODO: Need to test refresh token request for no internet connection and timed out

protocol AuthorizationRepository: RequestAdapter, RequestRetrier {
    var refreshFailedHandler: (() -> Void) { get set }
}

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
    
    // MARK: - Open properties for customization (by override)
    
    open var accessTokenKey: String {
        return "X-Auth-Token"
    }
    open var refreshTokenKey: String {
        return "X-Remember-Me-Token"
    }
    open var authorizationHeaderKey: String {
        return "X-Auth-Token"
    }
    open func fullAccessToken(_ accessToken: String) -> String {
        return accessToken
    }
    
    /// will be executed if refresh token is invalid (statusCode == 401 for urls.refreshAccessToken)
    open var refreshFailedHandler: (() -> Void) = {}
    
    // MARK: - Init
    
    init(urls: AuthorizationURLs, tokenStorage: TokenStorage) {
        self.urls = urls
        self.tokenStorage = tokenStorage
    }
}

extension AuthorizationRepositoryImp: RequestAdapter {
    
    public func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        guard let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix(urls.baseUrl.absoluteString) else {
            return urlRequest
        }
        
        var urlRequest = urlRequest
//        urlRequest.setValue("application/json; encoding=utf-8", forHTTPHeaderField: "Content-Type")
        
        
        
        guard let accessToken = tokenStorage.accessToken else {
            return urlRequest
        }
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
        
        /// if accessToken is valid
        if response.statusCode != 401 {
            completion(false, 0.0)
            return
        }
        
        /// if accessToken is invalid
//        if response.statusCode != 403 {
//            completion(false, 0.0)
//            return
//        }
        
        /// save request
        requestsToRetry.append(completion)
        
        /// guard refresh retry
        if isRefreshing {
            return
        }
        
        refreshTokens { [weak self] succeeded, accessToken in
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
    
    
    
    // MARK: - Private - Refresh Tokens
    
    fileprivate typealias RefreshCompletion = (_ succeeded: Bool, _ accessToken: String?) -> Void
    
    fileprivate func refreshTokens(completion: @escaping RefreshCompletion) {
        
        /// guard refresh retry
        if isRefreshing {
            return
        }
        
        /// start refresh status
        isRefreshing = true
        
        
        /// send request with refreshToken to get new accessToken
        
        let headers = [refreshTokenKey: tokenStorage.refreshToken ?? ""]
        
        sessionManager
            .request(urls.refreshAccessToken, method: .post, parameters: [:], encoding: JSONEncoding.default, headers: headers)
            .responseJSON { [weak self] response in
                guard let strongSelf = self else { return }
                debugPrint(response)
                
                // mapping accessToken for completion handler
                
                if
                    let headers = response.response?.allHeaderFields as? [String: Any],
                    let accessToken = headers[strongSelf.accessTokenKey] as? String
                {
                    completion(true, accessToken)
                } else {
                    /// if refresh token is invalid
                    strongSelf.refreshFailedHandler()
                    completion(false, nil)
                }
                
                // end refresh status
                strongSelf.isRefreshing = false
        }
    }
}

