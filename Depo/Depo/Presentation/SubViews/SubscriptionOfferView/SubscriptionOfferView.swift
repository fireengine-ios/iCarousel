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
            newValue.backgroundColor = ColorConstants.darkTintGray
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
            newValue.lineBreakMode = .byWordWrapping
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
    
    @IBOutlet private weak var detailsStackView: UIStackView!
    
    @IBOutlet private weak var paydayLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.font = UIFont.TurkcellSaturaFont(size: 15)
            newValue.textColor = ColorConstants.darkText
        }
    }
    
    @IBOutlet private weak var offerStoreLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.font = UIFont.TurkcellSaturaFont(size: 15)
            newValue.textColor = ColorConstants.darkText
            newValue.textAlignment = .right
        }
    }
    
    @IBOutlet private weak var featureView: SubscriptionFeaturesView!
    
    private weak var delegate: SubscriptionOfferViewDelegate?
    private var index: Int?

    func configure(with plan: SubscriptionPlan,
                   delegate: SubscriptionOfferViewDelegate,
                   index: Int,
                   style: Style,
                   needHidePurchaseInfo: Bool = true) {
        nameLabel.text = plan.name
        priceLabel.attributedText = makePrice(plan.price)
        detailsStackView.isHidden = needHidePurchaseInfo
        if let attributedText = makePackageFeature(plan: plan) {
            typeLabel.attributedText = attributedText
        } else {
            typeLabel.isHidden = true
        }
        
        updateDesign(with: plan, style: style)
        
        self.delegate = delegate
        self.index = index
    }
    
    func configure(with offer: PackageOffer,
                   delegate: SubscriptionOfferViewDelegate,
                   index: Int,
                   needHidePurchaseInfo: Bool = true) {
        guard let plan = offer.offers.first else {
            return
        }
        
        configure(with: plan, delegate: delegate, index: index, style: .full, needHidePurchaseInfo: needHidePurchaseInfo)
    }
    
    private func makePrice(_ price: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: price)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let priceAttributes: [NSAttributedString.Key: AnyObject] = [
            .font: UIFont(name: "TurkcellSatura-Bold", size: 16)!,
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
    
    private func makePackageFeature(plan: SubscriptionPlan) -> NSAttributedString? {
        guard let text = makePlanTypeText(plan: plan) else {
            return nil
        }
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
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: text, attributes: [
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ])
    }
    
    private func makePlanTypeText(plan: SubscriptionPlan) -> String? {
        guard let addonType = plan.addonType else {
            return nil
        }
        
        switch addonType {
        case .bundle:
            return TextConstants.bundlePackageAddonType
        case .storageOnly:
            return TextConstants.storageOnlyPackageAddonType
        case .featureOnly:
            return nil
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
    
    private func updateDesign(with plan: SubscriptionPlan, style: Style) {
        updateButton(plan: plan, style: style)
        updateDetails(plan: plan)
        updateFeaturesView(features: makeFeatures(plan: plan), style: style)
        updateBorderView(isRecommended: plan.isRecommended)
    }
    
    private func updateButton(plan: SubscriptionPlan, style: Style) {
        switch plan.type {
        case .current:
            purchaseButton.setBackgroundColor(.white, for: UIControl.State())
            purchaseButton.setTitle(TextConstants.cancel, for: UIControl.State())
            purchaseButton.setTitleColor(ColorConstants.marineTwo, for: UIControl.State())
            purchaseButton.layer.borderColor = ColorConstants.marineTwo.cgColor
            purchaseButton.layer.borderWidth = 1
            
        case .default:
            let isRecommended = plan.isRecommended
            let color: UIColor
            switch style {
            case .full:
                color = isRecommended ? ColorConstants.cardBorderOrange : ColorConstants.marineTwo
            case .short:
                let titleColor = plan.isRecommended ? ColorConstants.whiteColor : ColorConstants.marineTwo
                purchaseButton.setTitleColor(titleColor, for: UIControl.State())
                let borderColor = isRecommended ? ColorConstants.cardBorderOrange : ColorConstants.darkTintGray
                purchaseButton.layer.borderColor = borderColor.cgColor
                purchaseButton.layer.borderWidth = 2
                color = isRecommended ? ColorConstants.cardBorderOrange : ColorConstants.whiteColor
            }
            purchaseButton.setBackgroundColor(color, for: UIControl().state)
    
        case .free:
            purchaseButton.isEnabled = false
            purchaseButton.setTitle(nil, for: UIControl.State())
            purchaseButton.setBackgroundColor(.clear, for: UIControl.State())
        }
    }
    
    private func updateDetails(plan: SubscriptionPlan) {
        if plan.date.isEmpty, plan.store.isEmpty {
            detailsStackView.isHidden = true
        } else {
            paydayLabel.text = plan.date
            offerStoreLabel.text = plan.store
        }
    }
    
    private func updateFeaturesView(features: SubscriptionFeaturesView.Features, style: Style) {
        switch style {
        case .full:
            featureView.configure(features: features)
        case .short:
            featureView.configure(features: .storageOnly)
        }
    }
    
    private func updateBorderView(isRecommended: Bool) {
        let color = isRecommended ? ColorConstants.cardBorderOrange : ColorConstants.darkTintGray
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
