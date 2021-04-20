//
//  Error+Alamofire.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 3/5/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Alamofire

extension Error {
    var notAuthorized: Bool {
        if let afError = self as? AFError, afError.responseCode == 401 {
            return true
        }
        return false
    }
}
