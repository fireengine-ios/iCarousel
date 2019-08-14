//
//  SimpleSliderCell.swift
//  Depo
//
//  Created by Aleksandr on 5/11/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol SimpleSliderCellSetupProtocol {
    func setup(withItem item: SliderItem)
}

class SimpleSliderCell: UICollectionViewCell, SimpleSliderCellSetupProtocol {
    func setup(withItem item: SliderItem) {
        assertionFailure("😱OVERRIDE SETUP METHOD FOR THIS CELL😱")
    }
}
