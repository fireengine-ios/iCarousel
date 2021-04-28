//
//  ServerError.swift
//  Depo
//
//  Created by Darya Kuliashova on 8/14/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

//* 2FA Error Codes
enum TwoFAErrorCodes: Int {
    case unauthorized = 401
    case tooManyRequests = 429
    
    var statusCode: Int {
        return self.rawValue
    }
}
