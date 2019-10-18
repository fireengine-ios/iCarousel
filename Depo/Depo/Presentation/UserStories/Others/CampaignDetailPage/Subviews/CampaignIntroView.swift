//
//  CampaignIntroView.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 10/17/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class CampaignIntroView: UIView {

    @IBOutlet private weak var contentView: UIView! {
        willSet {
            newValue.layer.masksToBounds = false
            newValue.layer.cornerRadius = 4
            newValue.layer.shadowRadius = 5
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowOffset = .zero
            newValue.layer.shadowPath = UIBezierPath(rect: newValue.bounds).cgPath
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.campaignDetailIntroTitle
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.textColor = ColorConstants.darkText
        }
    }
    
    @IBOutlet private weak var giftLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.campaignDetailIntroGift
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 12)
            newValue.textColor = ColorConstants.textGrayColor
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
            newValue.textAlignment = .center
        }
    }
    
    @IBOutlet private weak var celebrationLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.campaignDetailIntroCelebration
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 12)
            newValue.textColor = ColorConstants.textGrayColor
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
            newValue.textAlignment = .center
        }
    }
    
    @IBOutlet private weak var nounCelebrationLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.campaignDetailIntroNounCelebration
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 12)
            newValue.textColor = ColorConstants.textGrayColor
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
            newValue.textAlignment = .center
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.shadowPath = UIBezierPath(rect: contentView.bounds).cgPath
    }
    
    func setup(with info: CampaignPhotopickStatus) {
        
    }
}
