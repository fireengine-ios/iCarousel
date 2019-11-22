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
        ///This way we fix our 11 error, when we are trying to downcast self to URLError
        //        return self is URLError
        return (self as NSError).domain == NSURLErrorDomain
    }
    
    var urlErrorCode: URLError.Code {
        ///This way we fix our 11 error, when we are trying to downcast self to URLError
        //        guard let urlError = self as? URLError else {
        return URLError.Code(rawValue: (self as NSError).code)
    }
    
    var errorCode: Int {
        return urlErrorCode.rawValue
    }
}
