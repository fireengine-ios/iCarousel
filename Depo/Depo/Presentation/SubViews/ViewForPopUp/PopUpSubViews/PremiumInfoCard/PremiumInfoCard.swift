//
//  PremiumInfoCard.swift
//  Depo_LifeTech
//
//  Created by Harbros-2 on 11/17/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class PremiumInfoCard: BaseCardView {

    @IBOutlet weak var viewFeaturesView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 16
        }
    }
    @IBOutlet weak var viewLine: UIView!
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
        
        titleLabel.font = .appFont(.medium, size: 16)
        titleLabel.textColor = AppColor.label.color

        messageLabel.font = .appFont(.bold, size: 14)
        messageLabel.textColor = AppColor.label.color

        becomePremiumButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
        becomePremiumButton.titleEdgeInsets = UIEdgeInsets(top: 6, left: 17, bottom: 6, right: 17)
        becomePremiumButton.setTitle(TextConstants.becomePremiumMember, for: .normal)

        crownImage.image = UIImage(named: "iconPremium")
    }
    
    func configurateWithType(viewType: OperationType) {
        if viewType == .premium {

            //let isPremium = AuthoritySingleton.shared.accountType.isPremium
            let isPremium = true
            self.isPremium = isPremium
            
            viewFeaturesView.translatesAutoresizingMaskIntoConstraints = false
            if isPremium {
                viewFeaturesView.heightAnchor.constraint(equalToConstant: 110).isActive = true
            } else {
                viewFeaturesView.heightAnchor.constraint(equalToConstant: 152).isActive = true
            }
            
            becomePremiumButton.isHidden = isPremium
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
        CardsManager.default.stopOperationWith(type: .premium)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bottomSpace : CGFloat = 16.0
        //let h = contentStackView.frame.origin.y + contentStackView.frame.size.height + bottomSpace
        let h = viewFeaturesView.frame.maxY + bottomSpace
        if calculatedH != h {
            calculatedH = h
        }

        //only in this place animation become
        self.becomePremiumButton.addSelectedAnimation()
    }
    
    @IBAction private func onBecomePremiumTap(_ sender: Any) {
        let router = RouterVC()
        let vc = router.premium()
        router.pushViewController(viewController: vc)
    }
}
