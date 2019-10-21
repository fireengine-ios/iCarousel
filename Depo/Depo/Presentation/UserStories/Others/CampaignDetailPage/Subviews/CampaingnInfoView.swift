//
//  CampaingnInfoView.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 10/17/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class CampaingnInfoView: UIView {

    @IBOutlet private weak var contentView: UIView! {
        willSet {
            newValue.layer.masksToBounds = false
            newValue.layer.cornerRadius = 4
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowOffset = .zero
            newValue.layer.shadowPath = UIBezierPath(rect: newValue.bounds).cgPath
        }
    }
    @IBOutlet private weak var roundShadowView: UIView! {
        willSet {
            newValue.layer.masksToBounds = false
            newValue.layer.cornerRadius = newValue.bounds.height * 0.5
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowOffset = .zero
            newValue.layer.shadowPath = UIBezierPath(roundedRect: newValue.layer.bounds, cornerRadius: newValue.layer.cornerRadius).cgPath
        }
    }
    
    @IBOutlet private weak var giftView: UIView! {
        willSet {
            newValue.layer.cornerRadius = newValue.frame.height * 0.5
            newValue.layer.masksToBounds = true
            newValue.backgroundColor = .white
        }
    }
    
    @IBOutlet private weak var giftImageView: UIImageView!
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.campaignDetailInfoTitle
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.textColor = ColorConstants.darkText
            newValue.textAlignment = .center
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.campaignDetailInfoDescription + "\n" + TextConstants.campaignDetailInfoDescription
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 14)
            newValue.textColor = ColorConstants.textGrayColor
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.shadowPath = UIBezierPath(rect: contentView.bounds).cgPath
    }
    
    func setup(with details: CampaignCardResponse) {
        titleLabel.text = details.title
        descriptionLabel.text = details.message
    }
}
