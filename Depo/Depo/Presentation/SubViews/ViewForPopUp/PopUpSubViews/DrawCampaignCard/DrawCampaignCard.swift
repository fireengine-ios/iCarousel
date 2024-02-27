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
            newValue.numberOfLines = 0
            newValue.textAlignment = .left
            newValue.lineBreakMode = .byWordWrapping
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
    
    @IBOutlet weak var endDateLabel: PaddingLabel! {
        willSet {
            newValue.numberOfLines = 1
            newValue.layer.backgroundColor = AppColor.background.cgColor
            newValue.font = .appFont(.medium, size: 12)
            newValue.textColor = AppColor.highlightColor.color
            newValue.textAlignment = .center
            newValue.paddingLeft = 15
            newValue.paddingRight = 15
            newValue.paddingTop = 8
            newValue.paddingBottom = 8
            newValue.layer.cornerRadius = 12
            newValue.clipsToBounds = true
        }
    }
    
    @IBOutlet private weak var actionButton: DarkBlueButton! {
        willSet {
            newValue.setTitle(localized(.drawDetailButton), for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 14)
        }
    }
    
    private var campaignId: Int = 0
    private var endDate: String = ""
    private var pageTitle: String = ""
    private lazy var router = RouterVC()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    override func set(object: HomeCardResponse?) {
        super.set(object: object)
        setupCard()
    }
    
    private func setupCard() {
        if let campaign = cardObject?.details?["campaignId"].int {
            campaignId = campaign
        }
        
        if let title = cardObject?.details?["title"].string {
            pageTitle = title
            titleLabel.text = title
        }
        
        if let message = cardObject?.details?["description"].string {
            messageLabel.text = message
        }
        
        if let url = cardObject?.details?["thumbnail"].url {
            imageView.loadImageData(with: url)
        }
        
        if let endDate = cardObject?.details?["endDate"].number {
            self.endDate = dateString(from: endDate)
            endDateLabel.text = "\(localized(.drawEnddate)) \(dateString(from: endDate))"
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
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .click, eventLabel: .discoverCampaignCard)
        let vc = router.drawCampaign(campaignId: campaignId, endDate: endDate, title: pageTitle)
        router.pushViewController(viewController: vc, animated: false)
    }
    
    private func dateString(from dateInterval: NSNumber) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: Date(timeIntervalSince1970: TimeInterval(dateInterval.doubleValue / 1000)))
    }
}
