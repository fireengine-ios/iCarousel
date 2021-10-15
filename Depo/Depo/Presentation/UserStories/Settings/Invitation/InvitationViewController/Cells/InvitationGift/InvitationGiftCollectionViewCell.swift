//
//  InvitationGiftCollectionViewCell.swift
//  Depo
//
//  Created by Alper Kırdök on 5.05.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

class InvitationGiftCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var giftNameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var giftBGView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        setupView()
    }

    private func setupView() {
        giftBGView.layer.borderWidth = 1.0
        giftBGView.layer.borderColor = ColorConstants.snackbarGray.cgColor
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
