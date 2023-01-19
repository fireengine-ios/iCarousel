//
//  LaunchCampaignCard.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 8/29/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class LaunchCampaignCard: BaseCardView {
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 16)
            newValue.textColor = AppColor.label.color
            newValue.text = TextConstants.launchCampaignCardTitle
        }
    }
    
    @IBOutlet private weak var messageLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.light, size: 14)
            newValue.textColor = AppColor.label.color
            newValue.text = TextConstants.launchCampaignCardMessage
        }
    }
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var actionButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.launchCampaignCardDetail, for: .normal)
            newValue.setTitleColor(AppColor.settingsButtonColor.color, for: .normal)
            newValue.setTitleColor(AppColor.settingsButtonColor.color, for: .highlighted)
            newValue.titleLabel?.font = .appFont(.bold, size: 14)
        }
    }
    
    @IBOutlet weak var campaignImageView: UIImageView!
    
    override func set(object: HomeCardResponse?) {
        super.set(object: object)
        
        
//        if let details = object?.details {
//            set(details: details)
//        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadImage()
    }
    
    private func loadImage() {
        URLSession.shared.dataTask(with: RouteRequests.launchCampaignImage) { [weak self] data, _, error in
            guard let data = data, error == nil else { 
                return
            }
            DispatchQueue.toMain {
                self?.imageView.image = UIImage(data: data)
                self?.campaignImageView.frame = CGRect(x: (self?.imageView.frame.maxY)! - 25.0, y: (self?.imageView.frame.maxY)! - 70.0, width: 50, height: 50)
            }
        }.resume()
    }
    
    override func deleteCard() {
        /// we don't need: super.deleteCard()
        CardsManager.default.manuallyDeleteCardsByType(type: .launchCampaign, homeCardResponse: cardObject)
        CardsManager.default.stopOperationWith(type: .launchCampaign, serverObject: cardObject)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bottomSpace: CGFloat = 16.0
        let h = actionButton.frame.origin.y + actionButton.frame.height + bottomSpace
        if calculatedH != h {
            calculatedH = h
            layoutIfNeeded()
        }
    }
    
    @IBAction private func onActionButton(_ sender: UIButton) {
        openLaunchCampaignUrl()
    }
    
    private func openLaunchCampaignUrl() {
        UIApplication.shared.openSafely(RouteRequests.launchCampaignDetail)
    }
}
