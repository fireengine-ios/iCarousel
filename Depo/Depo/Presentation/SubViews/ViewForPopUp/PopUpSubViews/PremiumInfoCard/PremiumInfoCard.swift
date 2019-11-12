//
//  PremiumInfoCard.swift
//  Depo_LifeTech
//
//  Created by Harbros-2 on 11/17/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class PremiumInfoCard: BaseCardView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var crownImage: UIImageView!
    @IBOutlet private weak var buttonContentView: UIView!
    @IBOutlet private weak var becomePremiumButton: GradientPremiumButton!
    @IBOutlet private weak var contentStackView: UIStackView!
    
    var isPremium: Bool = false

    override func configurateView() {
        super.configurateView()
        
        canSwipe = false
        
        titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 20)
        titleLabel.textColor = ColorConstants.darkText

        messageLabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
        messageLabel.textColor = ColorConstants.textGrayColor

        becomePremiumButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
        becomePremiumButton.titleEdgeInsets = UIEdgeInsetsMake(6, 17, 6, 17)
        becomePremiumButton.setTitle(TextConstants.becomePremiumMember, for: .normal)

        crownImage.image = UIImage(named: "crownSmall")
    }
    
    func configurateWithType(viewType: OperationType) {
        if viewType == .premium {

            let isPremium = AuthoritySingleton.shared.accountType.isPremium
            self.isPremium = isPremium
            
            buttonContentView.isHidden = isPremium
            crownImage.isHidden = isPremium

            messageLabel.text = isPremium ? TextConstants.premiumBannerMessage : TextConstants.standardBannerMessage
            titleLabel.text = isPremium ? TextConstants.premiumBannerTitle : TextConstants.standardBannerTitle
        }
    }

    override func viewWillShow() {
        super.viewWillShow()

        self.becomePremiumButton.addSelectedAnimation()
    }

    override func deleteCard() {
        super.deleteCard()
        CardsManager.default.stopOperationWithType(type: .premium)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bottomSpace : CGFloat = 21.0
        let h = contentStackView.frame.origin.y + contentStackView.frame.size.height + bottomSpace
        if calculatedH != h {
            calculatedH = h
        }

        //only in this place animation become
        self.becomePremiumButton.addSelectedAnimation()
    }
    
    @IBAction private func onBecomePremiumTap(_ sender: Any) {
        let router = RouterVC()
        let vc = router.premium(title: TextConstants.lifeboxPremium, headerTitle: TextConstants.becomePremiumMember)
        router.pushViewController(viewController: vc)
    }
}
