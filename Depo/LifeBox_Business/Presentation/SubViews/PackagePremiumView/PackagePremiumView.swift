//
//  PackagePremiumView.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 11/22/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class PackagePremiumView: UIView, NibInit {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var crownImage: UIImageView!
    @IBOutlet private weak var buttonContentView: UIView!
    @IBOutlet private weak var becomePremiumButton: GradientPremiumButton!
    @IBOutlet private weak var contentStackView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
        configurate()
    }

    private func setup() {
        titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 20)
        titleLabel.textColor = ColorConstants.darkText

        messageLabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
        messageLabel.textColor = ColorConstants.textGrayColor

        becomePremiumButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
        becomePremiumButton.titleEdgeInsets = UIEdgeInsetsMake(6, 17, 6, 17)
        becomePremiumButton.setTitle(TextConstants.becomePremiumMember, for: .normal)

        crownImage.image = UIImage(named: "crownSmall")
    }

    private func configurate() {

        messageLabel.text = TextConstants.standardBannerMessage
        titleLabel.text = TextConstants.standardBannerTitle
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        //only in this place animation become
        self.becomePremiumButton.addSelectedAnimation()
    }

    @IBAction private func onBecomePremiumTap(_ sender: Any) {
        let router = RouterVC()
        let vc = router.premium()
        router.pushViewController(viewController: vc)
    }
}
