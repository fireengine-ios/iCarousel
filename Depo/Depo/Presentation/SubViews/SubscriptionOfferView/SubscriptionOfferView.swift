//
//  SubscriptionOfferView.swift
//  Depo
//
//  Created by Raman Harhun on 2/21/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol SubscriptionOfferViewDelegate: AnyObject {
    func didPressSubscriptionPlanButton(planIndex: Int, storageOfferType: StorageOfferType)
}

// Extend it according to storage offering
enum StorageOfferType {
    case subscriptionPlan, packageOffer
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
            newValue.textColor = AppColor.marineTwoAndWhite.color
            newValue.adjustsFontSizeToFitWidth = true
            newValue.lineBreakMode = .byWordWrapping
        }
    }

    private let priceIntroFont = UIFont.TurkcellSaturaFont(size: 17)
    @IBOutlet private weak var priceLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.textColor = AppColor.marineTwoAndWhite.color
        }
    }
    
    @IBOutlet private weak var typeLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var purchaseButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitleColor(.white, for: UIControl.State())
            newValue.insets = UIEdgeInsets(topBottom: 0, rightLeft: 12)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
            newValue.adjustsFontSizeToFitWidth()
        }
    }

    @IBOutlet private weak var introductoryPurchaseButtonContainer: UIView!
    @IBOutlet private weak var introductoryPurchaseButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitleColor(.white, for: UIControl.State())
            newValue.insets = UIEdgeInsets(topBottom: 0, rightLeft: 12)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
            newValue.adjustsFontSizeToFitWidth()
        }
    }

    @IBOutlet private weak var detailsView: UIView!
    
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
    
    @IBOutlet private weak var gracePeriodStackView: UIStackView! {
        willSet {
            newValue.spacing = 20
            newValue.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 16, right: 20)
            newValue.isLayoutMarginsRelativeArrangement = true
        }
    }
    
    @IBOutlet private weak var graceDateLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 14)
            newValue.textColor = ColorConstants.darkText
        }
    }
    
    @IBOutlet private weak var graceDescriptionLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.font = UIFont.TurkcellSaturaFont(size: 15)
            newValue.textColor = ColorConstants.switcherGrayColor
            newValue.text = localized(.gracePackageDescription)
        }
    }
    
    @IBOutlet private weak var featureView: SubscriptionFeaturesView!

    @IBOutlet private weak var purchaseButtonWidthConstraint: NSLayoutConstraint! {
        willSet {
            purchaseButtonWidth = newValue.constant
        }
    }

    private var purchaseButtonWidth: CGFloat!

    private weak var delegate: SubscriptionOfferViewDelegate?
    private var index: Int?
    private var storageOfferType: StorageOfferType = .subscriptionPlan

    func configure(with plan: SubscriptionPlan,
                   delegate: SubscriptionOfferViewDelegate,
                   index: Int,
                   style: Style,
                   needHidePurchaseInfo: Bool = true) {

        let hasIntroPrice = plan.introductoryPrice != nil

        nameLabel.text = plan.name
        if hasIntroPrice {
            priceLabel.text = plan.introductoryPrice
            priceLabel.font = priceIntroFont
            priceLabel.textAlignment = .center
        } else {
            priceLabel.attributedText = makePrice(plan.price)
        }
        purchaseButton.isHidden = hasIntroPrice
        introductoryPurchaseButtonContainer.isHidden = !hasIntroPrice
        purchaseButtonWidthConstraint.constant = hasIntroPrice ? 0 : purchaseButtonWidth
        detailsView.isHidden = needHidePurchaseInfo
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
        // It is already set to SubscriptionPlan so no need to reset in configure with SubscriptionPlan plan
        self.storageOfferType = .packageOffer
    }
    
    private func makePrice(_ price: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: price)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let priceAttributes: [NSAttributedString.Key: AnyObject] = [
            .font: UIFont.TurkcellSaturaBolFont(size: 16),
            .foregroundColor: AppColor.marineTwoAndWhite.color,
            .paragraphStyle: paragraphStyle
        ]
        
        let currencyAttributes: [NSAttributedString.Key: AnyObject] = [
            .font: UIFont.TurkcellSaturaFont(size: 16),
            .foregroundColor: AppColor.marineTwoAndWhite.color,
            .paragraphStyle: paragraphStyle
        ]
        
        let fullRange = attributedString.mutableString.range(of: price)
        attributedString.addAttributes(currencyAttributes, range: fullRange)
        
        let words = price.components(separatedBy: "\n")
        if let priceWord = words[safe: 0] {
            let priceRange = attributedString.mutableString.range(of: priceWord)
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
        
        if plan.addonType == .storageOnly {
            font = UIFont.TurkcellSaturaFont(size: 14)
            textColor = AppColor.marineTwoAndWhite.color
        } else {
            font = UIFont.TurkcellSaturaBolFont(size: 14)
            textColor = ColorConstants.cardBorderOrange
        }
        
        return NSAttributedString(string: text, attributes: [
            .font: font,
            .foregroundColor: textColor,
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
            return TextConstants.featuresOnlyAddonType
        case .middleOnly:
            return TextConstants.middleFeaturesOnlyAddonType
        }
    }
    
    private func makeFeatures(plan: SubscriptionPlan) -> SubscriptionFeaturesView.Features {
        let features = plan.features
        if plan.isRecommended {
            return .recommended(features: features)
        } else if features.isEmpty {
            return .storageOnly
        } else {
            return plan.addonType == .middleOnly ? .middleFeatures : .features(features)
        }
    }
    
    private func updateDesign(with plan: SubscriptionPlan, style: Style) {
        [purchaseButton, introductoryPurchaseButton].forEach { button in
            updateButton(button: button, plan: plan, style: style)
        }
        //updateDetails(plan: plan)
        updateFeaturesView(features: makeFeatures(plan: plan), style: style)
        updateBorderView(isRecommended: plan.isRecommended)
        //updateGracePeriodView(plan: plan)
    }
    
    private func updateButton(button: RoundedInsetsButton, plan: SubscriptionPlan, style: Style) {
        switch plan.type {
        case .current:
            button.setBackgroundColor(.white, for: UIControl.State())
            button.setTitle(TextConstants.cancel, for: UIControl.State())
            button.setTitleColor(ColorConstants.marineTwo, for: UIControl.State())
            button.layer.borderColor = ColorConstants.marineTwo.cgColor
            button.layer.borderWidth = 1
            
        case .default:
            let isRecommended = plan.isRecommended
            let color: UIColor
            switch style {
            case .full:
                color = AppColor.marineTwoAndTealish.color
                button.setTitle(TextConstants.purchase, for: UIControl.State())
            case .short:
                let titleColor = plan.isRecommended ? ColorConstants.whiteColor : AppColor.marineTwoAndWhite.color
                button.setTitleColor(titleColor, for: UIControl.State())
                let borderColor = isRecommended ? ColorConstants.marineTwo : ColorConstants.darkTintGray
                button.layer.borderColor = borderColor.cgColor
                button.layer.borderWidth = 2
                color = isRecommended ? AppColor.marineTwoAndTealish.color : .clear
                button.setTitle(TextConstants.upgrade, for: UIControl.State())
            }
            button.setBackgroundColor(color, for: UIControl().state)
    
        case .free:
            button.isEnabled = false
            button.setTitle(nil, for: UIControl.State())
            button.setBackgroundColor(.clear, for: UIControl.State())
        }
    }
    
    private func updateDetails(plan: SubscriptionPlan) {
        if plan.date.isEmpty, plan.store.isEmpty {
            detailsView.isHidden = true
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
            featureView.configure(features: .premiumOnly)
        }
    }
    
    private func updateBorderView(isRecommended: Bool) {
        let color = isRecommended ? ColorConstants.cardBorderOrange : ColorConstants.darkTintGray
        recommendationLabel.isHidden = !isRecommended
        borderView.backgroundColor = color
    }
    
    private func updateGracePeriodView(plan: SubscriptionPlan) {
        if plan.packageStatus != SubscribedPackageStatus.gracePeriod.rawValue {
            return
        }

        gracePeriodStackView.isHidden = false
        detailsView.isHidden = true
        featureView.isHidden = true
        recommendationLabel.isHidden = false
        purchaseButton.isHidden = true
        borderView.backgroundColor = .lrButterScotch
        recommendationLabel.text = localized(.gracePackageTitle)
        graceDateLabel.text = String(format: localized(.gracePackageExpirationDateTitle), "\(plan.gracePeriodEndDate)")
    }

    @IBAction private func onPurchaseTap(_ sender: UIButton) {
        guard let index = index else {
            return
        }
        delegate?.didPressSubscriptionPlanButton(planIndex: index, storageOfferType: storageOfferType)
    }
}
