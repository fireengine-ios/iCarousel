//
//  ErrorPresenter.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 3/19/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol ErrorPresenter {
    func showErrorAlert(message: String)
}
extension ErrorPresenter where Self: UIViewController {
    func showErrorAlert(message: String) {
        if presentedViewController is PopUpController {
            return
        } 
        let vc = PopUpController.with(errorMessage: message)
        vc.open()
    }
}
