//
//  ReachabilityService.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 6/27/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import Reachability


protocol ReachabilityProtocol  {
    
    var isReachableViaWWAN: Bool { get }
    
    var isReachableViaWiFi: Bool { get }
    
    var isReachable: Bool { get }
}

class ReachabilityService: ReachabilityProtocol {
    
    private let reachability  = Reachability()!
    
    var isReachableViaWiFi: Bool {
        return self.reachability.connection == .wifi
    }
    
    var isReachableViaWWAN: Bool {
        return self.reachability.connection == .cellular
    }
    
    var isReachable:Bool {
        return self.reachability.connection != .none
    }
    
    init() {
        self.reachability.whenReachable = { (Reachability) in
            //
        }
        
        self.reachability.whenUnreachable = { (Reachability) in
            //
        }
        
        do {
            try self.reachability.startNotifier()
        } catch {
            print("Can't start REACHABILITY_NOTIFIER")
        }
    }
}

