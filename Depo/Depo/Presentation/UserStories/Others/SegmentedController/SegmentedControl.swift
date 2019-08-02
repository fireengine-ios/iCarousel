//
//  SegmentedControl.swift
//  Depo_LifeTech
//
//  Created by Igor Bunevich on 7/26/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation
import UIKit

final class SegmentedControl: UISegmentedControl {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        allSubviews(of: UILabel.self)
            .forEach { $0.adjustsFontSizeToFitWidth() }
    }
}
