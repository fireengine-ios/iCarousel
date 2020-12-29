//
//  ControlTabBarProtocol.swift
//  Depo
//
//  Created by Harbros 3 on 2/8/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

protocol ControlTabBarProtocol {
    
    func showTabBar()
    func hideTabBar()
    
}

extension ControlTabBarProtocol {
    
    func showTabBar() {
        NotificationCenter.default.post(name: .showTabBar, object: nil)
    }
    
    func hideTabBar() {
        NotificationCenter.default.post(name: .hideTabBar, object: nil)
    }
    
}
