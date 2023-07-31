//
//  DescriptionView.swift
//  Depo
//
//  Created by yahya cagri ozturk on 18.07.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import UIKit

final class DescriptionView: UIView, FromNib {
    @IBOutlet weak var descriptionLabel: UILabel! {
        willSet {
            newValue.backgroundColor = .clear
            newValue.textColor = AppColor.blackColor.color
            newValue.font = .appFont(.regular, size: 14.0)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
    }
}
