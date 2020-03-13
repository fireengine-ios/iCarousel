//
//  PackagesTableViewCell.swift
//  Depo
//
//  Created by Raman Harhun on 2/27/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

class PackagesTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.textColor = UIColor.lrBrownishGrey
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 16)
            newValue.textColor = UIColor.lrLightBrownishGrey
            newValue.textAlignment = .right
            newValue.numberOfLines = 0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryType = .disclosureIndicator
        selectionStyle = .none
    }
    
    func configure(type: ControlPackageType) {
        switch type {
        case .myProfile:
            titleLabel.text = TextConstants.myProfile

        case .myStorage(let type):
            titleLabel.text = TextConstants.myPackages
            descriptionLabel.text = type?.text

        case .usage(percentage: let percentage):
            titleLabel.text = TextConstants.usage
            let percentageString = percentage.rounded(.toNearestOrAwayFromZero)
            let usage = String(format: TextConstants.usagePercentage, percentageString)
            descriptionLabel.text = usage

        case .accountType(let type):
            titleLabel.text = type.text
            descriptionLabel.isHidden = true
        }
    }
}
