//
//  BorderDotsPageControl.swift
//  Depo
//
//  Created by Andrei Novikau on 10/23/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class BorderDotsPageControl: UIPageControl {
    
    var borderColor: UIColor = .clear {
        didSet {
            updateBorderColor()
        }
    }

    override var currentPage: Int {
        didSet {
            updateBorderColor()
        }
    }

    func updateBorderColor() {
        guard Device.operationSystemVersionLessThen(14) else {
            return
        }
        
        subviews.forEach { subview in
            subview.layer.borderColor = borderColor.cgColor
            subview.layer.borderWidth = 1
        }
    }
}
