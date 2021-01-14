//
//  UIAlertController+Action.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 4/24/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

extension UIAlertController {
    func addActions(_ actions: UIAlertAction...) {
        actions.forEach { addAction($0) }
    }
}
