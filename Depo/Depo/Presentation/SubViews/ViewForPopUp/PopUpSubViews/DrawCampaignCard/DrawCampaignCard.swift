//
//  DrawCampaignCard.swift
//  Depo
//
//  Created by Ozan Salman on 23.02.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

final class DrawCampaignCard: BaseCardView {
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 16)
            newValue.textColor = AppColor.label.color
        }
    }
    
    @IBOutlet private weak var messageLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.light, size: 14)
            newValue.textColor = AppColor.label.color
        }
    }
    
    @IBOutlet private weak var imageView: LoadingImageView! {
        willSet {
            newValue.contentMode = .scaleToFill
        }
    }
    
    @IBOutlet private weak var actionButton: DarkBlueButton! {
        willSet {
            newValue.setTitle("Kampanya Detayları", for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 14)
        }
    }
    
    private var campaignId: Int = 0
    
    override func set(object: HomeCardResponse?) {
        super.set(object: object)
        setupCard()
    }
    
    private func setupCard() {
        if let campaign = cardObject?.details?["campaignId"].int {
            campaignId = campaign
        }
        
        if let title = cardObject?.details?["title"].string {
            titleLabel.text = title
        }
        
        if let message = cardObject?.details?["description"].string {
            messageLabel.text = message
        }
        
        if let url = cardObject?.details?["thumbnail"].url {
            imageView.loadImageData(with: url)
        }
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
        print("aaaaaaaaaaaa \(campaignId)")
    }
}
