//
//  ColorCell.swift
//  Depo
//
//  Created by Andrei Novikau on 7/28/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class ColorCell: UICollectionViewCell {
    
    @IBOutlet private weak var colorView: UIView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = newValue.frame.height * 0.5
        }
    }
    
    @IBOutlet private weak var selectedView: UIView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.borderWidth = 2
            newValue.layer.cornerRadius = newValue.frame.height * 0.5
            newValue.backgroundColor = .clear
        }
    }
    
    override var isSelected: Bool {
        didSet {
            selectedView.isHidden = !isSelected
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = ColorConstants.filterBackColor
    }
    
    func setup(color: UIColor) {
        colorView.backgroundColor = color
        selectedView.layer.borderColor = color.cgColor
        selectedView.isHidden = !isSelected
    }

}
