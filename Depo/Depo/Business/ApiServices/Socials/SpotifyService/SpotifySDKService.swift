//
//  SpotifySDKService.swift
//  Depo_LifeTech
//
//  Created by Maxim Soldatov on 9/5/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

protocol SpotifySDKServiceDelegate {
    func showSpotifyAuthWebViewController()
    func continueSpotifySDKConnectionWithCode(code: String)
}

final class SpotifySDKService: NSObject {
    
    private var delegate: SpotifySDKServiceDelegate?
    private var spotifyClientID: String?
    private var spotifyRedirectURI: URL?
    private lazy var router = RouterVC()
    private let applicationQueriesScheme = "akillidepo://"
    
    init(url: URL?, delegate: SpotifySDKServiceDelegate) {
        super.init()
        self.delegate = delegate
        self.parseSpotifyUrl(url: url)
    }
            
    private lazy var sessionManager: SPTSessionManager? = {
        if let clientID = spotifyClientID, let redirectUrl = spotifyRedirectURI {
            let configuration = SPTConfiguration(clientID: clientID, redirectURL: redirectUrl)
            let manager = SPTSessionManager(configuration: configuration, delegate: self)
            return manager
        }
        return nil
    }()
    
    func connectToSporify() {
        guard let manager = sessionManager else {
            delegate?.showSpotifyAuthWebViewController()
            return
        }
        
        manager.isSpotifyAppInstalled ? connectToSpotifyWithSDK() : delegate?.showSpotifyAuthWebViewController()
    }
    
    private func connectToSpotifyWithSDK() {
        
        let scope: SPTScope = [.appRemoteControl, .playlistReadPrivate, .userLibraryRead]
        
        if #available(iOS 11, *) {
            sessionManager?.initiateSession(with: scope, options: .clientOnly)
        } else {
            if let controller = self.router.navigationController?.viewControllers.last {
                sessionManager?.initiateSession(with: scope, options: .clientOnly, presenting: controller)
            }
        }
    }
    
    private func parseSpotifyUrl(url: URL?) {
        
        guard let urlString = url?.absoluteString,
              let startIndexForClientID = urlString.range(of: "client_id=")?.upperBound,
              let endIndexForClientID = urlString.range(of: "&response_type")?.lowerBound,
              let startIndexForRedirectUrl = urlString.range(of: "redirect_uri=https%3A%2F%2F")?.upperBound,
              let endIndexForRedirectUrl = urlString.range(of: "&scope")?.lowerBound else {
                assertionFailure()
                return
        }
        let clientID = urlString[startIndexForClientID..<endIndexForClientID]
        let redirectURLFromServer = urlString[startIndexForRedirectUrl..<endIndexForRedirectUrl]
        let redirectURL = applicationQueriesScheme.appending(redirectURLFromServer)
        
        spotifyClientID = String(clientID)
        spotifyRedirectURI = URL(string: redirectURL)
    }
    
    func handleRedirectUrl(url: URL) -> Bool {
        
        guard let urlString = URLComponents(string: url.absoluteString) else {
            assertionFailure()
            return false
        }
        
        if let code = urlString.queryItems?.first(where: { $0.name == "code"})?.value {
             delegate?.continueSpotifySDKConnectionWithCode(code: code)
        } else {
            delegate?.showSpotifyAuthWebViewController()
        }
        return true
    }
}

extension SpotifySDKService: SPTSessionManagerDelegate {
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        delegate?.showSpotifyAuthWebViewController()
    }
}




