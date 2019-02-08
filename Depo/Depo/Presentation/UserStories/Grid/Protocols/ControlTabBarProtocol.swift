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
        let notificationName = NSNotification.Name(rawValue: TabBarViewController.notificationShowTabBar)
        NotificationCenter.default.post(name: notificationName, object: nil)
    }
    
    func hideTabBar() {
        let notificationName = NSNotification.Name(rawValue: TabBarViewController.notificationHideTabBar)
        NotificationCenter.default.post(name: notificationName, object: nil)
    }
    
}
