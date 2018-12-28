//
//  LeavePremiumRouterInput.swift
//  Depo
//
//  Created by Harbros 3 on 11/21/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

protocol LeavePremiumRouterInput: class {
    func goToBack()
    func showAlert(with text: String)
    func showError(with text: String)
}
