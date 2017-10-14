//
//  SingletonRouterStorrage.swift
//  Depo
//
//  Created by Oleg on 13.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class SingletonRouterStorrage: NSObject {
    
    private static var uniqueInstance: SingletonRouterStorrage?
    
    var topViewController: UIViewController? = nil
    
    private override init() {}
    
    static func shared() -> SingletonRouterStorrage {
        if uniqueInstance == nil {
            uniqueInstance = SingletonRouterStorrage()
        }
        return uniqueInstance!
    }
    
    func dismisTopViewController(){
        guard let controller = topViewController else {
            return
        }
        if let view = controller.view{
            view.removeFromSuperview()
        }
        topViewController = nil
    }
    
}
