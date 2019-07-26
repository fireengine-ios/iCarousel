//
//  SegmentedControl.swift
//  Depo_LifeTech
//
//  Created by Igor Bunevich on 7/26/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation
import UIKit

class SegmentedControl: UISegmentedControl {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labels = allSubviews().compactMap { $0 as? UILabel }
        labels.forEach { $0.adjustsFontSizeToFitWidth() }
    }
}
