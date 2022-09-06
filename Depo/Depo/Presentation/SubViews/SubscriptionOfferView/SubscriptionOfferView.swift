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
            newValue.layer.cornerRadius = 16
        }
    }
    
    @IBOutlet private weak var recommendationLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 12)
            newValue.backgroundColor = .clear
            newValue.textAlignment = .center
            newValue.textColor = .white
            newValue.text = TextConstants.weRecommend
        }
    }
    @IBOutlet weak var topStackView: UIStackView! {
        willSet {
            newValue.backgroundColor = ColorConstants.darkTintGray
            newValue.layer.cornerRadius = 16
        }
    }
    
    @IBOutlet private weak var plateView: UIView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = 16
        }
    }
    
    @IBOutlet private weak var nameLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 14)
            newValue.textColor = AppColor.marineTwoAndWhite.color
            newValue.adjustsFontSizeToFitWidth = true
            newValue.lineBreakMode = .byWordWrapping
        }
    }

    private let priceIntroFont = UIFont.appFont(.medium, size: 14)
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

    @IBOutlet private weak var detailsView: UIView!
    
    @IBOutlet private weak var paydayLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.font = UIFont.appFont(.regular, size: 15)
            newValue.textColor = ColorConstants.darkText
        }
    }
    
    @IBOutlet private weak var offerStoreLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.font = UIFont.appFont(.regular, size: 15)
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
            newValue.font = .appFont(.regular, size: 12)
            newValue.textColor = ColorConstants.darkText
        }
    }
    
    @IBOutlet private weak var graceDescriptionLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.font = .appFont(.regular, size: 12)
            newValue.textColor = ColorConstants.switcherGrayColor
            newValue.text = localized(.gracePackageDescription)
        }
    }
    
    @IBOutlet private weak var featureView: SubscriptionFeaturesView!
    
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
            priceLabel.text = plan.price
        }
        featureView.purchaseButton.isHidden = hasIntroPrice
        detailsView.isHidden = needHidePurchaseInfo
        if let attributedText = makePackageFeature(plan: plan) {
            typeLabel.attributedText = attributedText
        } else {
            typeLabel.isHidden = true
        }
        
        updateDesign(with: plan, style: style)
        
        featureView.delegate = delegate
        featureView.index = index
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
        featureView.storageOfferType = .packageOffer
    }
    
    private func makePackageFeature(plan: SubscriptionPlan) -> NSAttributedString? {
        guard let text = makePlanTypeText(plan: plan) else {
            return nil
        }
        let textColor: UIColor
        let font: UIFont
        
        if plan.addonType == .storageOnly {
            font = UIFont.appFont(.regular, size: 16)
            textColor = AppColor.marineTwoAndWhite.color
        } else {
            font = UIFont.appFont(.bold, size: 16)
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
        
        updateButton(button: featureView.purchaseButton, plan: plan, style: style)
        
        updateDetails(plan: plan)
        updateFeaturesView(features: makeFeatures(plan: plan), style: style)
        updateBorderView(isRecommended: plan.isRecommended)
        updateGracePeriodView(plan: plan)
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
            switch style {
            case .full:
                button.setTitle(TextConstants.purchase, for: UIControl.State())
            case .short:
                let titleColor = plan.isRecommended ? ColorConstants.whiteColor : AppColor.marineTwoAndWhite.color
                button.setTitleColor(titleColor, for: UIControl.State())
                let borderColor = isRecommended ? ColorConstants.marineTwo : ColorConstants.darkTintGray
                button.layer.borderColor = borderColor.cgColor
                button.layer.borderWidth = 2
                button.setTitle(TextConstants.upgrade, for: UIControl.State())
            }
            button.setBackgroundColor(AppColor.forYouButton.color, for: UIControl().state)
    
        case .free:
            featureView.purchaseButtonHeightConstaint.constant = 0
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
        recommendationLabel.isHidden = !isRecommended
        if isRecommended {
            plateView.layer.cornerRadius = 16
            plateView.clipsToBounds = true
            plateView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            
//            let gradient = gradientBorderView(view: borderView)
//            borderView.clipsToBounds = true
//            borderView.layer.insertSublayer(gradient, at: 0)
//
            let gradient = gradientBorderView(view: topStackView)
            topStackView.clipsToBounds = true
            topStackView.layer.insertSublayer(gradient, at: 0)
        }
    }
    
    private func gradientBorderView(view: UIView) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.type = .axial
        gradient.colors = [
            AppColor.SettingsPackagesRecommendedOne.cgColor,
            AppColor.SettingsPackagesRecommendedTwo.cgColor,
            AppColor.SettingsPackagesRecommendedThree.cgColor,
            AppColor.SettingsPackagesRecommendedFour.cgColor
        ]
        gradient.frame = view.bounds
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.6, y: 0.6)
        return gradient
    }
    
    private func updateGracePeriodView(plan: SubscriptionPlan) {
        if plan.packageStatus != SubscribedPackageStatus.gracePeriod.rawValue {
            return
        }

        gracePeriodStackView.isHidden = false
        detailsView.isHidden = true
        featureView.isHidden = true
        recommendationLabel.isHidden = false
        featureView.purchaseButton.isHidden = true
        topStackView.backgroundColor = .lrButterScotch
        recommendationLabel.text = localized(.gracePackageTitle)
        graceDateLabel.text = String(format: localized(.gracePackageExpirationDateTitle), "\(plan.gracePeriodEndDate)")
    }
}
