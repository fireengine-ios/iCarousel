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
    
    let passcodeStorage: PasscodeStorage = factory.resolve()
    
    func setup() {
        let auth: AuthorizationRepository = factory.resolve()
        let sessionManager: SessionManager = factory.resolve()
        sessionManager.retrier = auth
        sessionManager.adapter = auth
    }
    
    var isNeedToShowPasscode: Bool {
        return !passcodeStorage.isEmpty
    }
}
