//
//  LaunchCampaignCard.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 8/29/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class LaunchCampaignCard: BaseView {
    
    @IBOutlet private weak var titleView: UIView! {
        willSet {
            newValue.backgroundColor = UIColor.lrTealish
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.textColor = UIColor.white
            newValue.text = "titleLabel"
        }
    }
    
    @IBOutlet private weak var messageLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 16)
            newValue.textColor = ColorConstants.darcBlueColor
            newValue.text = "messageLabel"
        }
    }
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var actionButton: UIButton! {
        willSet {
            newValue.setTitle("actionButton", for: .normal)
            newValue.setTitleColor(UIColor.lrTealishTwo, for: .normal)
            newValue.setTitleColor(UIColor.lrTealishTwo.darker(), for: .highlighted)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
        }
    }
    
    override func set(object: HomeCardResponse?) {
        super.set(object: object)
        
//        if let details = object?.details {
//            set(details: details)
//        }
    }
    
    override func deleteCard() {
        super.deleteCard()
        CardsManager.default.stopOperationWithType(type: .launchCampaign, serverObject: cardObject)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bottomSpace: CGFloat = 0.0
        let h = actionButton.frame.origin.y + actionButton.frame.height + bottomSpace
        if calculatedH != h {
            calculatedH = h
            layoutIfNeeded()
        }
    }
    
    @IBAction private func onActionButton(_ sender: UIButton) {
        
    }
}
