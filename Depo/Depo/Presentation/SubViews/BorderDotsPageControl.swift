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
        subviews.enumerated().forEach { index, subview in
            subview.layer.borderColor = borderColor.cgColor
            subview.layer.borderWidth = 1
        }
    }
}
