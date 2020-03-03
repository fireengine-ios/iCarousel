//
//  SubscriptionOfferView.swift
//  Depo
//
//  Created by Raman Harhun on 2/21/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol SubscriptionOfferViewDelegate: class {
    func didPressSubscriptionPlanButton(planIndex: Int)
}

final class SubscriptionOfferView: UIView, NibInit {

    enum Style {
        case full
        case short
    }
    
    @IBOutlet private weak var borderView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.lightGrayColor
            newValue.layer.cornerRadius = 8
        }
    }
    
    @IBOutlet private weak var recommendationLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaFont(size: 16)
            newValue.backgroundColor = .clear
            newValue.textAlignment = .center
            newValue.textColor = .white
            newValue.text = TextConstants.weRecommend
        }
    }
    
    @IBOutlet private weak var plateView: UIView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = 8
        }
    }
    
    @IBOutlet private weak var nameLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 24)
            newValue.textColor = ColorConstants.marineTwo
            newValue.adjustsFontSizeToFitWidth = true
        }
    }
    
    @IBOutlet private weak var priceLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var typeLabel: UILabel! {
           willSet {
               newValue.numberOfLines = 0
           }
       }
    
    @IBOutlet private weak var purchaseButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitle(TextConstants.upgrade, for: UIControl.State())
            newValue.setTitleColor(.white, for: UIControl.State())
            newValue.insets = UIEdgeInsets(topBottom: 0, rightLeft: 12)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var featureView: SubscriptionFeaturesView!
    
    private weak var delegate: SubscriptionOfferViewDelegate?
    private var index: Int?

    func configure(with plan: SubscriptionPlan, delegate: SubscriptionOfferViewDelegate, index: Int, style: Style) {
        nameLabel.text = plan.name
        priceLabel.attributedText = makePrice(plan.priceString)
        typeLabel.attributedText = makePackageFeature(plan: plan)
        
        switch style {
        case .full:
            featureView.configure(features: makeFeatures(plan: plan))
        case .short:
            featureView.configure(features: .storageOnly)
        }
        
        updateButton(isRecommended: plan.isRecommended)
        updateBorderView(isRecommended: plan.isRecommended)
        
        self.delegate = delegate
        self.index = index
    }
    
    func configure(with offer: PackageOffer, delegate: SubscriptionOfferViewDelegate, index: Int) {
        guard let plan = offer.offers.first else {
            return
        }
        
        configure(with: plan, delegate: delegate, index: index, style: .full)
    }
    
    private func makePrice(_ price: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: price)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let priceAttributes: [NSAttributedString.Key: AnyObject] = [
            .font: UIFont.TurkcellSaturaBolFont(size: 16),
            .foregroundColor: ColorConstants.marineTwo,
            .paragraphStyle: paragraphStyle
        ]
        
        let currencyAttributes: [NSAttributedString.Key: AnyObject] = [
            .font: UIFont.TurkcellSaturaFont(size: 16),
            .foregroundColor: ColorConstants.marineTwo,
            .paragraphStyle: paragraphStyle
        ]
        
        let fullRange = attributedString.mutableString.range(of: price)
        attributedString.addAttributes(currencyAttributes, range: fullRange)
        
        let words = price.components(separatedBy: " ")
        if let price = words[safe: 0] {
            let priceRange = attributedString.mutableString.range(of: price)
            attributedString.addAttributes(priceAttributes, range: priceRange)
        }
        
        return attributedString
    }
    
    private func makePackageFeature(plan: SubscriptionPlan) -> NSAttributedString {
        let textColor: UIColor
        let font: UIFont
        
        if plan.isRecommended {
            font = UIFont.TurkcellSaturaBolFont(size: 16)
            textColor = ColorConstants.cardBorderOrange
        } else if plan.addonType == .storageOnly {
            font = UIFont.TurkcellSaturaFont(size: 16)
            textColor = ColorConstants.darkText
        } else {
            font = UIFont.TurkcellSaturaBolFont(size: 16)
            textColor = ColorConstants.marineTwo
        }
        
        let text = makePlanTypeText(plan: plan)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: text, attributes: [
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ])
    }
    
    private func makePlanTypeText(plan: SubscriptionPlan) -> String {
        guard let addonType = plan.addonType else {
            return ""
        }
        
        switch addonType {
        case .bundle:
            return TextConstants.bundlePackageAddonType
        case .storageOnly:
            return TextConstants.storageOnlyPackageAddonType
        case .featureOnly:
            return ""
        }
    }
    
    private func makeFeatures(plan: SubscriptionPlan) -> SubscriptionFeaturesView.Features {
        let features = plan.features
        if plan.isRecommended {
            return .recommended(features: features)
        } else if features.isEmpty {
            return .storageOnly
        } else {
            return .features(features)
        }
    }
    
    private func updateButton(isRecommended: Bool) {
        let color = isRecommended ? ColorConstants.cardBorderOrange : ColorConstants.marineTwo
        purchaseButton.setBackgroundColor(color, for: UIControl().state)
    }
    
    private func updateBorderView(isRecommended: Bool) {
        let color = isRecommended ? ColorConstants.cardBorderOrange : ColorConstants.lightGrayColor
        recommendationLabel.isHidden = !isRecommended
        borderView.backgroundColor = color
    }
    
    @IBAction private func onPurchaseTap(_ sender: UIButton) {
        guard let index = index else {
            return
        }
        delegate?.didPressSubscriptionPlanButton(planIndex: index)
    }
}
