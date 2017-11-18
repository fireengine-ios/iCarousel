//
//  SpringLabel.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/17/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

open class SpringLabel: UILabel {
    
    open lazy var duration = 0.1
    
    open override var text: String? {
        didSet {
            UIView.animate(withDuration: duration) {
                self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
            UIView.animate(withDuration: duration, delay: duration, options: [], animations: {
                self.transform = .identity
            }, completion: nil)
        }
    }
}
