//
//  TopBarCustomSegmentedCell.swift
//  Depo
//
//  Created by Alex Developer on 31.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//


final class TopBarCustomSegmentedCell: UICollectionViewCell {
    
    @IBOutlet private weak var label: UILabel! {
        willSet {
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 14)
            newValue.textColor = ColorConstants.Text.labelTitle.color
        }
    }
    
    override var isSelected: Bool {
        didSet {
            label.font = isSelected ?  UIFont.GTAmericaStandardMediumFont(size: 14) : UIFont.GTAmericaStandardRegularFont(size: 14)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = ColorConstants.topBarColor.color
    }
    
    func setup(title: String) {
        label.text = title
    }
    
}
