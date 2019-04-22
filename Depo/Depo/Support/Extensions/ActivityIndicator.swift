//
//  ActivityIndicator.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 3/29/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol ActivityIndicator {
    func startActivityIndicator()
    func stopActivityIndicator()
}
extension ActivityIndicator where Self: UIViewController {
    func startActivityIndicator() {
        showSpinner()
    }
    func stopActivityIndicator() {
        hideSpinner()
    }
}
