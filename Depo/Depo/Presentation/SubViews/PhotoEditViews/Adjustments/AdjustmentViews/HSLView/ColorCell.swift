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
            newValue.layer.borderWidth = 1
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
        contentView.backgroundColor = ColorConstants.photoEditBackgroundColor
    }
    
    func setup(hsvColor: HSVMultibandColor) {
        colorView.backgroundColor = hsvColor.color
        selectedView.layer.borderColor = hsvColor.color.cgColor
        selectedView.isHidden = !isSelected
    }

}
