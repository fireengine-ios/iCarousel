//
//  CollectionViewHeaderWithText.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 10.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class CollectionViewHeaderWithText: UICollectionReusableView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with text: String) {
        titleLabel.text = text
        titleLabel.font = .appFont(.medium, size: 14)
        titleLabel.textColor = AppColor.label.color
    }
}
