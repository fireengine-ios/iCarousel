//
//  SelectionMenuCell.swift
//  Depo
//
//  Created by Andrei Novikau on 7/30/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class SelectionMenuCell: UITableViewCell {

    enum Style {
        case simple
        case checkmark
    }
    
    @IBOutlet private weak var stackView: UIStackView! {
        willSet {
            newValue.spacing = Device.isIpad ? 10 : 5
        }
    }
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 15)
            newValue.textColor = .white
        }
    }
    
    @IBOutlet private weak var checkmarkImageView: UIImageView! {
        willSet {
            newValue.tintColor = .white
        }
    }
    
    @IBOutlet private weak var leadingContraint: NSLayoutConstraint!
    
    private var style: Style = .simple
    
    override var isSelected: Bool {
        didSet {
            
            checkmarkImageView.image = isSelected ? Image.iconSelect.image.withRenderingMode(.alwaysTemplate) : nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = ColorConstants.photoEditBackgroundColor
        leadingContraint.constant = Device.isIpad ? 20 : 16
    }
    
    func setup(style: Style, title: String, isSelected: Bool) {
        self.style = style
        checkmarkImageView.isHidden = style == .simple
        titleLabel.text = title
    }
}
