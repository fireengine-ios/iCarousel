//
//  RaffleCard.swift
//  Depo
//
//  Created by Ozan Salman on 26.03.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

final class RaffleCard: BaseCardView {
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
            newValue.isUserInteractionEnabled = true
            let tapImage = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            newValue.addGestureRecognizer(tapImage)
        }
    }
    
    @IBOutlet private weak var actionButton: DarkBlueButton! {
        willSet {
            newValue.setTitle(localized(.drawDetailButton), for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 14)
        }
    }
    
    private var id: Int = 0
    private var pageTitle: String = ""
    private lazy var router = RouterVC()
    private var detailUrl: String = ""
    private var conditionImageUrl: String = ""
    private var startDate: String = ""
    private var endDate: String = ""
    private var drawEndDateText: String = ""
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    override func set(object: HomeCardResponse?) {
        super.set(object: object)
        setupCard()
    }
    
    private func setupCard() {
        if let id = cardObject?.details?["id"].int {
            self.id = id
        }
        
        if let title = cardObject?.details?["title"].string {
            pageTitle = title
            titleLabel.text = title
        }
        
        if let message = cardObject?.details?["description"].string {
            messageLabel.text = message
        }
        
        if let url = cardObject?.details?["imagePath"].url {
            imageView.loadImageData(with: url)
        }
        
        if let detailUrl = cardObject?.details?["detailImagePath"].string {
            self.detailUrl = detailUrl
        }
        
        if let startDate = cardObject?.details?["startDate"].number {
            self.startDate = dateString(from: startDate)
        }
        
        if let endDate = cardObject?.details?["endDate"].number {
            self.endDate = dateString(from: endDate)
        }
        
        if let conditionImage = cardObject?.details?["extraData"]["conditionImagePath"].string {
            self.conditionImageUrl = conditionImage
        }
        
        drawEndDateText = "\(localized(.gamificationRaffleDates)) \(startDate) - \(endDate)"
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
        goToRafflePage()
    }
    
    @objc private func imageTapped() {
        goToRafflePage()
    }
    
    private func goToRafflePage() {
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .click, eventLabel: .gamification)
        let vc = router.raffle(id: id, url: detailUrl, endDateText: drawEndDateText, conditionImageUrl: conditionImageUrl)
        router.pushViewController(viewController: vc, animated: false)
    }
    
    private func dateString(from dateInterval: NSNumber) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: Date(timeIntervalSince1970: TimeInterval(dateInterval.doubleValue / 1000)))
    }
}
