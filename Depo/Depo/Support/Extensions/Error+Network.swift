//
//  Error+Network.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 2/28/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

extension Error {
    
    var isUnknownError: Bool {
        return self.urlErrorCode == .unknown
    }
    
    var isNetworkError: Bool {
        return self is URLError
    }
    
    var urlErrorCode: URLError.Code {
        guard let urlError = self as? URLError else {
            return .unknown
        }
        
        return urlError.code
    }
    
    var errorCode: Int {
        return urlErrorCode.rawValue
    }
}
