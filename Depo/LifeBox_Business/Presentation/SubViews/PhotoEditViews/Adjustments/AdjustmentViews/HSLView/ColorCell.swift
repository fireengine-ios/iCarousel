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
        }
    }
    
    @IBOutlet private weak var selectedView: UIView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.borderWidth = Device.isIpad ? 2 : 1
            newValue.backgroundColor = .clear
        }
    }
    
    @IBOutlet private weak var sizeConstraint: NSLayoutConstraint!
    @IBOutlet private weak var borderSizeConstraint: NSLayoutConstraint!
    
    override var isSelected: Bool {
        didSet {
            selectedView.isHidden = !isSelected
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = ColorConstants.photoEditBackgroundColor
        sizeConstraint.constant = Device.isIpad ? 36 : 20
        borderSizeConstraint.constant = Device.isIpad ? 44 : 24
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        colorView.layer.cornerRadius = colorView.frame.height * 0.5
        selectedView.layer.cornerRadius = selectedView.frame.height * 0.5
    }
    
    func setup(hsvColor: HSVMultibandColor) {
        colorView.backgroundColor = hsvColor.color
        selectedView.layer.borderColor = hsvColor.color.cgColor
        selectedView.isHidden = !isSelected
    }

}
