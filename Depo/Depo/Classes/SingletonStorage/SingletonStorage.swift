//
//  SingletonStorage.swift
//  Depo
//
//  Created by Oleg on 01.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class SingletonStorage: NSObject {
    
    private static var uniqueInstance: SingletonStorage?
    
    var isAppraterInited: Bool = false
    
    private override init() {}
    
    static func shared() -> SingletonStorage {
        if uniqueInstance == nil {
            uniqueInstance = SingletonStorage()
        }
        return uniqueInstance!
    }
}
