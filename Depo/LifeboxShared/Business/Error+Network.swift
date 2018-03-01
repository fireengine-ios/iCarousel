//
//  Error+Network.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 2/28/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import Alamofire

extension Error {
    var isNetworkError: Bool {
        return self is URLError
    }
    
    var notAuthorized: Bool {
        if let afError = self as? AFError, afError.responseCode == 401 {
            return true
        }
        return false
    }
    
    var parsedDescription: String {
        if isNetworkError {
            return L10n.Error.internet
        } else if notAuthorized {
            return L10n.Error.login
        }
        return localizedDescription
    }
}
