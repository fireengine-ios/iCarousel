//
//  PackagesTableViewCell.swift
//  Depo
//
//  Created by Raman Harhun on 2/27/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

class PackagesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.regular, size: 14)
            newValue.textColor = AppColor.label.color
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.regular, size: 14)
            newValue.textColor = AppColor.billoGrayAndWhite.color
            newValue.textAlignment = .right
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet private weak var infoImageView: UIImageView!
    @IBOutlet private weak var titleLabelLeadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryType = .disclosureIndicator
        selectionStyle = .none
    }
    
    func configure(type: ControlPackageType) {
        infoImageView.isHidden = true

        switch type {
        case .myProfile:
            titleLabel.text = TextConstants.myProfile

        case .myStorage(let type):
            titleLabel.text = TextConstants.myPackages
            descriptionLabel.text = type?.text
            infoImageView.isHidden = !(SingletonStorage.shared.subscriptionsContainGracePeriod)
            
        case .usage(percentage: let percentage):
            titleLabel.text = TextConstants.usage
            let percentageString = (percentage * 100).rounded(.toNearestOrAwayFromZero)
            let usage = String(format: TextConstants.usagePercentage, percentageString)
            descriptionLabel.text = usage
            
        case .connectedAccounts:
            titleLabel.text = TextConstants.settingsViewCellConnectedAccounts
            descriptionLabel.text = ""

        case .accountType(let type):
            titleLabel.text = type.text
            descriptionLabel.isHidden = true
            
            switch type {
            case.premium:
                infoImageView.isHidden = false
                infoImageView.image = Image.iconPremium.image
            case .standard:
                infoImageView.isHidden = true
            case .middle:
                infoImageView.isHidden = true
            }
        }
        
        let titleLeadingConstraint: CGFloat = infoImageView.isHidden ? 16 : 48
        titleLabelLeadingConstraint.constant = titleLeadingConstraint
    }
}
