//
//  WidgetTokenService.swift
//  LifeboxWidgetExtension
//
//  Created by Roman Harhun on 02/09/2020.
//  Copyright © 2020 LifeTech. All rights reserved.

import Foundation
import Alamofire

struct WidgetHeaderConstant {
    static let AuthToken = "X-Auth-Token"
    static let RememberMeToken = "X-Remember-Me-Token"
}

typealias RefreshCompletion = (_ succeeded: Bool, _ accessToken: String?, _ error: Error?) -> Void

final class WidgetTokenService {
    
    var isAuthorized: Bool { tokenStorage.accessToken != nil }

    var refreshFailedHandler: VoidHandler?
    
    private static let maxRefreshAttempts = 3

    private var isRefreshing = false
    private var refreshAttempts = 0
    private var refreshTokensCompletions = [RefreshCompletion]()
    
    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        return SessionManager(configuration: configuration)
    }()
    
    private let tokenStorage: TokenStorage
    
    init(tokenStorage: TokenStorage) {
        self.tokenStorage = tokenStorage
    }
    
    func refreshTokens(completion: @escaping RefreshCompletion) {
        /// start refresh status
        isRefreshing = true
        
        /// send request with refreshToken to get new accessToken
        let headers = [WidgetHeaderConstant.RememberMeToken: tokenStorage.refreshToken ?? ""]
        
        sessionManager
            .request(
                URL(string: "https://adepo.turkcell.com.tr/api/auth/rememberMe")!,
                method: .post,
                parameters: Device.deviceInfo,
                encoding: JSONEncoding.default,
                headers: headers
            )
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
                    strongSelf.refreshFailedHandler?()
                    completion(false, nil, nil)
                    strongSelf.isRefreshing = false
                    strongSelf.refreshTokensCompletions.forEach { $0(false, nil, nil) }
                    strongSelf.refreshTokensCompletions.removeAll()
                
                /// mapping accessToken for completion handler
                } else if let headers = response.response?.allHeaderFields as? [String: Any],
                    let accessToken = headers[WidgetHeaderConstant.AuthToken] as? String {
                    completion(true, accessToken, nil)
                    strongSelf.isRefreshing = false
                    strongSelf.refreshTokensCompletions.forEach { $0(true, accessToken, nil) }
                    strongSelf.refreshTokensCompletions.removeAll()
                    
                /// retry refreshTokens request only for bad internet
                } else if strongSelf.refreshAttempts < Self.maxRefreshAttempts {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        strongSelf.refreshAttempts += 1
                        strongSelf.isRefreshing = false
                        strongSelf.refreshTokens(completion: completion)
                    }
                } else {
                    completion(false, nil, response.error)
                    strongSelf.isRefreshing = false
                    strongSelf.refreshTokensCompletions.forEach { $0(false, nil, nil) }
                    strongSelf.refreshTokensCompletions.removeAll()
                }
        }
    }
}
