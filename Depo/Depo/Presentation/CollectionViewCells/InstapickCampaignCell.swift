//
//  InstapickCampaignCell.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 10/18/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class InstapickCampaignCell: UICollectionViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.textColor = ColorConstants.darkText
            newValue.numberOfLines = 0
            newValue.text = TextConstants.campaignDetailContestInfoTitle
        }
    }
    
    @IBOutlet private weak var totalTitleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 14)
            newValue.textColor = ColorConstants.textGrayColor
            newValue.numberOfLines = 0
            newValue.text = TextConstants.campaignDetailContestInfoTotalDraw
        }
    }
    
    @IBOutlet private weak var totalCountLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 24)
            newValue.textColor = ColorConstants.textGrayColor
            newValue.numberOfLines = 1
            newValue.text = " "
        }
    }
    
    @IBOutlet private weak var leftTitleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 14)
            newValue.textColor = ColorConstants.textGrayColor
            newValue.numberOfLines = 0
            newValue.text = TextConstants.campaignDetailContestInfoRemainingDraw
        }
    }
    
    @IBOutlet private weak var leftCountLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 24)
            newValue.textColor = ColorConstants.textGrayColor
            newValue.numberOfLines = 1
            newValue.text = " "
        }
    }
    
    @IBOutlet private weak var actionButton: UIButton! {
        willSet {
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
            newValue.setTitleColor(ColorConstants.blueColor, for: .normal)
            newValue.setTitle(TextConstants.campaignDetailTitle, for: .normal)
        }
    }
    
    @IBOutlet private weak var shadowView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 5
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowRadius = 5
            newValue.layer.shadowOpacity = 0.3
            newValue.layer.shadowOffset = .zero
        }
    }
    
    @IBOutlet private weak var borderView: UIView! {
        willSet {
            newValue.clipsToBounds = true
            newValue.layer.cornerRadius = 5
        }
    }
    
    func setup(with status: CampaignPhotopickStatus) {
        totalCountLabel.text = "\(status.usage.totalUsed)"
        leftCountLabel.text = "\(status.usage.dailyRemaining)"
    }
    
    @IBAction private func onActionButton(_ sender: UIButton) {
        // TODO: wating for FE-1682
        print("+ TODO: wating for FE-1682")
    }
}
