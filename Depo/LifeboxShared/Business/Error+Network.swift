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
            return "Please check your internet connection is active and Mobile Data is ON."
        } else if notAuthorized {
            return "You have not login via app yet"
        }
        return localizedDescription
    }
}
