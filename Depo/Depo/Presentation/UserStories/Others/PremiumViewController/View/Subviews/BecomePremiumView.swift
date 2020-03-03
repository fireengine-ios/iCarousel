//
//  BecomePremiumView.swift
//  Depo
//
//  Created by Andrei Novikau on 3/2/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol BecomePremiumViewDelegate: class {
    func didSelectSubscriptionPlan(_ plan: SubscriptionPlan)
    func didTapSeeAllPackages()
}

final class BecomePremiumView: UIView, NibInit {

    @IBOutlet private weak var scrollView: UIScrollView! {
        willSet {
            newValue.backgroundColor = ColorConstants.lighterGray
        }
    }
    
    @IBOutlet private weak var contentView: UIStackView! {
        willSet {
            newValue.alignment = .center
            newValue.spacing = 24
        }
    }
    
    @IBOutlet private weak var headerTitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.becomePremiumHeaderTitle
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 20)
            newValue.textColor = ColorConstants.marineTwo
            newValue.textAlignment = .center
        }
    }
    
    @IBOutlet private weak var headerSubtitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.becomePremiumHeaderSubtitle
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 16)
            newValue.textColor = .lrLightBrownishGrey
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.becomePremiumDescription
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 18)
            newValue.textColor = ColorConstants.marineTwo
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
            newValue.backgroundColor = ColorConstants.lighterGray
        }
    }
    
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
    
    private var plans = [SubscriptionPlan]()
    weak var delegate: BecomePremiumViewDelegate?
    
    //MARK: - Setup
    
    func configure(with plans: [SubscriptionPlan]) {
        guard !plans.isEmpty else {
            return
        }
        
        self.plans = plans
        
        contentView.arrangedSubviews.forEach { contentView.removeArrangedSubview($0) }
        
        for (index, plan) in plans.enumerated() {
            if index > 0 {
                contentView.addArrangedSubview(orLabel)
                if #available(iOS 11.0, *) {
                    contentView.setCustomSpacing(12, after: orLabel)
                }
            }
            
            let view = SubscriptionOfferView.initFromNib()
            view.configure(with: plan, delegate: self, index: index, style: .short)
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
    
    //MARK: - Actions
    
    @objc private func onSeeAllPackages(_ sender: UIButton) {
        delegate?.didTapSeeAllPackages()
    }
}

extension BecomePremiumView: SubscriptionOfferViewDelegate {
    func didPressSubscriptionPlanButton(planIndex: Int) {
        guard let plan = plans[safe: planIndex] else {
            return
        }
        
        delegate?.didSelectSubscriptionPlan(plan)
    }
}
