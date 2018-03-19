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
        let vc = PopUpController.with(errorMessage: message)
        present(vc, animated: false, completion: nil)
    }
}
