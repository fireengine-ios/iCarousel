//
//  ShareConfigurator.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 2/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import Alamofire

let factory: SharedFactory = FactoryBase()

final class ShareConfigurator {
    
    func setup() {
        let urls: AuthorizationURLs = AuthorizationURLsImp()
        let tokenStorage: TokenStorage = factory.resolve()
        
        var auth: AuthorizationRepository = AuthorizationRepositoryImp(urls: urls, tokenStorage: tokenStorage)
        auth.refreshFailedHandler = { [weak self] in
            //            self?.dismiss(animated: true, completion: nil)
        }
        
        let sessionManager: SessionManager = factory.resolve()
        sessionManager.retrier = auth
        sessionManager.adapter = auth
    }
}
