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
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = .TurkcellSaturaDemFont(size: 13)
            newValue.textColor = .white
        }
    }
    
    @IBOutlet private weak var checkmarkImageView: UIImageView!
    
    private var style: Style = .simple
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = ColorConstants.filterBackColor
    }
    
    func setup(style: Style, title: String, isSelected: Bool) {
        self.style = style
        if style == .checkmark {
            setSeleted(isSelected)
        } else {
            checkmarkImageView.isHidden = true
        }
        
        titleLabel.text = title
    }
    
    func setSeleted(_ isSelected: Bool) {
        checkmarkImageView.image = isSelected ? UIImage(named: "applyIcon") : nil
    }
}
