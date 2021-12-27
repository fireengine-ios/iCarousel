//
//  UIButton+Color.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 12/13/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        if #available(iOS 13.0, *) {
            let traitCollection = (UIApplication.shared.delegate as? AppDelegate)?.window?.traitCollection ?? self.traitCollection
            traitCollection.performAsCurrent {
                let image = UIImage(color: color)
                setBackgroundImage(image, for: state)
            }
        } else {
            let image = UIImage(color: color)
            setBackgroundImage(image, for: state)
        }
    }
}
