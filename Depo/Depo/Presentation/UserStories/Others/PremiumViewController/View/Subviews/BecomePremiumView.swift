//
//  BecomePremiumView.swift
//  Depo
//
//  Created by Andrei Novikau on 3/2/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol BecomePremiumViewDelegate: class {
    func didSelectSubscriptionPlan(_ offer: PackageOffer)
    func didTapSeeAllPackages()
}

final class BecomePremiumView: UIView, NibInit {
    
    @IBOutlet private weak var scrollView: ControlContainableScrollView! {
        willSet {
            newValue.backgroundColor = ColorConstants.lighterGray
            newValue.delaysContentTouches = false
        }
    }
    
    @IBOutlet private weak var contentView: UIStackView! {
        willSet {
            newValue.alignment = .center
            newValue.spacing = 12
        }
    }
    
    @IBOutlet private weak var headerTitleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 20)
            newValue.textColor = ColorConstants.marineTwo
            newValue.textAlignment = .center
        }
    }
    
    @IBOutlet private weak var headerSubtitleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 16)
            newValue.textColor = .lrLightBrownishGrey
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet weak var headerStackView: UIStackView!
    
    private lazy var descriptionStackView: UIStackView = {
        let newValue = UIStackView()
        newValue.axis = .vertical
        newValue.spacing = 3
        return newValue
    }()
    
    private lazy var policyView = SubscriptionsPolicyView()
    
    private lazy var seeAllPackagesButton: RoundedInsetsButton = {
        let button = RoundedInsetsButton()
        button.heightAnchor.constraint(equalToConstant: 44).activate()
        button.widthAnchor.constraint(equalToConstant: 208).activate()
        
        button.adjustsFontSizeToFitWidth()
        button.setTitle(TextConstants.becomePremiumSeeAllPackages, for: .normal)
        button.setTitleColor(ColorConstants.marineTwo, for: .normal)
        button.insets = UIEdgeInsets(topBottom: 0, rightLeft: 12)
        button.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
        button.setBackgroundColor(.white, for: .normal)
        
        button.layer.borderColor = ColorConstants.darkTintGray.cgColor
        button.layer.borderWidth = 2
        
        button.addTarget(self, action: #selector(onSeeAllPackages(_:)), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var orLabel: UILabel = {
        let label = UILabel()
        label.text = TextConstants.becomePremiumOrText
        label.font = UIFont.TurkcellSaturaMedFont(size: 16)
        label.textColor = .lrBrownishGrey
        return label
    }()
    
    private var plans = [PackageOffer]()
    weak var delegate: BecomePremiumViewDelegate?
    var source = BecomePremiumViewSourceType.default {
        didSet {
            headerTitleLabel.text = source.title
            headerSubtitleLabel.text = source.subtitle
        }
    }
    
    //MARK: - Setup
    
    func configure(with plans: [PackageOffer]) {
        guard !plans.isEmpty else {
            return
        }
        
        self.plans = plans
        
        contentView.arrangedSubviews.forEach { contentView.removeArrangedSubview($0) }
        
        let features = plans
            .flatMap { $0.offers }
            .flatMap { $0.features }
            .map { $0.description }
            .removingDuplicates()

        addDescription([TextConstants.featureStandardFeatures] + features)
        
        for (index, plan) in plans.enumerated() {
            guard let offer = plan.offers.first else {
                return
            }
            
            if index > 0 {
                contentView.addArrangedSubview(orLabel)
                if #available(iOS 11.0, *) {
                    contentView.setCustomSpacing(12, after: orLabel)
                }
            }
            
            let view = SubscriptionOfferView.initFromNib()
            view.configure(with: offer, delegate: self, index: index, style: .short)
            view.backgroundColor = ColorConstants.lighterGray
            contentView.addArrangedSubview(view)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            
            if Device.isIpad {
                view.widthAnchor.constraint(equalToConstant: 440).activate()
            } else {
                view.widthAnchor.constraint(equalTo: contentView.widthAnchor).activate()
            }
            
            if #available(iOS 11.0, *) {
                contentView.setCustomSpacing(16, after: orLabel)
            }
        }
        
        contentView.addArrangedSubview(seeAllPackagesButton)
        contentView.addArrangedSubview(policyView)
    }
    
    private func addDescription(_ features: [String]) {
        guard !features.isEmpty else {
            return
        }
        
        features.forEach { feature in
            let label = UILabel()
            label.text = feature
            label.font = UIFont.TurkcellSaturaMedFont(size: 18)
            label.textColor = ColorConstants.cardBorderOrange
            label.textAlignment = .center
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            descriptionStackView.addArrangedSubview(label)
        }
        
        descriptionStackView.widthAnchor.constraint(equalToConstant: 200).activate()
        headerStackView.addArrangedSubview(descriptionStackView)
    }
    
    //MARK: - Actions
    
    @objc private func onSeeAllPackages(_ sender: UIButton) {
        delegate?.didTapSeeAllPackages()
    }
}

//MARK: - SubscriptionOfferViewDelegate

extension BecomePremiumView: SubscriptionOfferViewDelegate {
    func didPressSubscriptionPlanButton(planIndex: Int) {
        guard let offer = plans[safe: planIndex] else {
            return
        }
        
        delegate?.didSelectSubscriptionPlan(offer)
    }
}
