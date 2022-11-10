//
//  InvitationGiftCollectionViewCell.swift
//  Depo
//
//  Created by Alper Kırdök on 5.05.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

class InvitationGiftCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var giftNameLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.campaignLightLabel.color
            newValue.font = .appFont(.bold, size: 14)
        }
    }
    
    @IBOutlet weak var typeLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.regular, size: 12)
        }
    }
    
    @IBOutlet weak var expirationDateLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.regular, size: 12)
        }
    }
    
    @IBOutlet weak var giftBGView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 8
            newValue.layer.borderWidth = 1
            newValue.layer.borderColor = AppColor.campaignBorder.cgColor
        }
    }
    
    func configureCell(subscriptionPlan: SubscriptionPlan) {
        giftNameLabel.text = subscriptionPlan.name
        typeLabel.text = makePlanTypeText(plan: subscriptionPlan)
        expirationDateLabel.text = subscriptionPlan.date
    }

    private func makePlanTypeText(plan: SubscriptionPlan) -> String {
        switch plan.addonType {
        case .bundle:
            return TextConstants.bundlePackageAddonType
        case .storageOnly:
            return TextConstants.storageOnlyPackageAddonType
        case .featureOnly:
            return TextConstants.featuresOnlyAddonType
        case .middleOnly:
            return TextConstants.middleFeaturesOnlyAddonType
        case .none:
            return ""
        }
    }
}
