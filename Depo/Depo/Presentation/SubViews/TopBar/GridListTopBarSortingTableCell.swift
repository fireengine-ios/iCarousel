//
//  GridListTopBarSortingTableCell.swift
//  Depo
//
//  Created by Aleksandr on 9/8/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class GridListTopBarSortingTableCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var sortImage: UIImageView!
    @IBOutlet private weak var approveImage: UIImageView! {
        willSet {
            newValue.image = Image.iconSelectCheck.image(withTintColor: .filesLabel, in: newValue)
        }
    }
    
    func setup(withText text: String, selected: Bool, icon: Image) {
        titleLabel.text = text
        titleLabel.accessibilityLabel = text
        titleLabel.font = .appFont(.medium, size: 16)
        titleLabel.textColor = AppColor.filesLabel.color
        sortImage.image = icon.image
        approveImage.isHidden = selected ? false : true
    }
    
    func changeState(selected: Bool) {
        approveImage.isHidden = selected ? false : true
    }
    
}
