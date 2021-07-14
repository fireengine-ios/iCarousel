//
//  ActivityIndicatorManager.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/9/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class ActivityIndicatorManager {
    
    private var startNumber = 0
    private var isStarted = false
    
    weak var delegate: ActivityIndicatorManagerDelegate?
    
    func start() {
        startNumber += 1
        if !isStarted {
            isStarted = true
            delegate?.showIndicator()
        }
    }
    
    func stop() {
        /// if more then 0
        if startNumber != 0 {
            startNumber -= 1
        }
        /// if became 0
        if startNumber == 0 {
            isStarted = false
            delegate?.hideIndicator()
        }
    }
}

protocol ActivityIndicatorManagerDelegate: AnyObject {
    func showIndicator()
    func hideIndicator()
}

extension UIViewController: ActivityIndicatorManagerDelegate {
    func showIndicator() {
        showSpinner()
    }
    
    func hideIndicator() {
        hideSpinner()
    }
}
