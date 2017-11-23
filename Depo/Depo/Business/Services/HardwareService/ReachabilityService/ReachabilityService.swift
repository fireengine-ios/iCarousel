//
//  ReachabilityService.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 6/27/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import ReachabilitySwift


protocol ReachabilityProtocol  {
    
    var isReachableViaWWAN: Bool { get }
    
    var isReachableViaWiFi: Bool { get }
    
    var isReachable: Bool { get }
}

class ReachabilityService: ReachabilityProtocol {
    
    private let reachability  = Reachability()!
    
    var isReachableViaWiFi: Bool {
        return self.reachability.isReachableViaWiFi
    }
    
    var isReachableViaWWAN: Bool {
        return self.reachability.isReachableViaWWAN
    }
    
    var isReachable:Bool {
        return self.reachability.isReachable
    }
    
    init() {
        self.reachability.whenReachable = { (Reachability) in
            //
        }
        
        self.reachability.whenUnreachable = { (Reachability) in
            //
        }
    }
}
