//
//  SubscriptionFeaturesView.swift
//  Depo
//
//  Created by Raman Harhun on 2/21/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class SubscriptionFeaturesView: UIView {
    
    enum Features {
        case storageOnly
        case recommended(features: [AuthorityType])
        case features(_ features: [AuthorityType])
        case middleFeatures
        case premiumOnly
    }
    
    private lazy var stackView: UIStackView = {
        let newValue = UIStackView()
        newValue.axis = .vertical
        newValue.spacing = 1
        return newValue
    }()
    
    private lazy var showButton: UIButton = {
        let newValue = UIButton(type: .custom)
        newValue.titleLabel?.font = .appFont(.medium, size: 14)
        
        // normal
        newValue.setTitle(TextConstants.showMore, for: .normal)
        newValue.setTitleColor(ColorConstants.textGrayColor, for: .normal)
        newValue.setImage(Image.iconArrowDownActive.image, for: .normal)
        
        // selected
        newValue.setTitle(TextConstants.showLess, for: .selected)
        newValue.setTitleColor(ColorConstants.textGrayColor, for: .selected)
        newValue.setImage(Image.iconArrowUpActive.image, for: .selected)
        
        newValue.forceImageToRightSide()
        
        newValue.addTarget(self, action: #selector(onCollapseTap), for: .touchUpInside)
        return newValue
    }()
    
    lazy var purchaseButton: RoundedInsetsButton = {
        let view = RoundedInsetsButton()
        view.setTitleColor(.white, for: UIControl.State())
        view.insets = UIEdgeInsets(topBottom: 0, rightLeft: 12)
        view.titleLabel?.font = .appFont(.medium, size: 16)
        view.addTarget(self, action: #selector(onPurchaseTap), for: .touchUpInside)
        view.adjustsFontSizeToFitWidth()
        return view
    }()
    
    var purchaseButtonHeightConstaint: NSLayoutConstraint = .init()
    var purchaseButtonHeight: CGFloat = 45
    
    weak var delegate: SubscriptionOfferViewDelegate?
    var index: Int?
    var storageOfferType: StorageOfferType = .subscriptionPlan
    
    private var features: Features = .features([])
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubviews()
        makeConstraints()
    }
    
    func configure(features: Features) {
        self.features = features
        prepareInitialState()
    }
    
    private func addSubviews() {
        addSubview(stackView)
        addSubview(showButton)
//        addSubview(dividerLineView)
        addSubview(purchaseButton)
    }
    
    private func makeConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: self.topAnchor).activate()
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).activate()
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).activate()
        stackView.bottomAnchor.constraint(equalTo: purchaseButton.topAnchor, constant: -8).activate()
        
        showButton.translatesAutoresizingMaskIntoConstraints = false
        showButton.heightAnchor.constraint(equalToConstant: 40).activate()
        showButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).activate()
        showButton.leadingAnchor.constraint(equalTo: self.leadingAnchor).activate()
        showButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).activate()
        
//        dividerLineView.translatesAutoresizingMaskIntoConstraints = false
//        dividerLineView.heightAnchor.constraint(equalToConstant: 1).activate()
//        dividerLineView.bottomAnchor.constraint(equalTo: self.showButton.topAnchor).activate()
//        dividerLineView.leadingAnchor.constraint(equalTo: self.showButton.leadingAnchor).activate()
//        dividerLineView.trailingAnchor.constraint(equalTo: self.showButton.trailingAnchor).activate()
        
        purchaseButton.translatesAutoresizingMaskIntoConstraints = false
        purchaseButtonHeightConstaint = purchaseButton.heightAnchor.constraint(equalToConstant: purchaseButtonHeight)
        purchaseButtonHeightConstaint.activate()
        purchaseButton.bottomAnchor.constraint(equalTo: self.showButton.topAnchor).activate()
        purchaseButton.leadingAnchor.constraint(equalTo: self.showButton.leadingAnchor,
                                                constant: 44).activate()
        purchaseButton.trailingAnchor.constraint(equalTo: self.showButton.trailingAnchor,
                                                 constant: -44).activate()
    }
    
    private func prepareInitialState() {
        switch features {
        case .features, .middleFeatures, .storageOnly:
            break
            
        case .premiumOnly:
            removeCollapseButton(offsetFromBottom: 0)
            
        case .recommended(features: let features):
            removeCollapseButton(offsetFromBottom: -8)
            addFeatures([TextConstants.featureStandardFeatures])
            addFeatures(features.map({ $0.description }), isPremium: true)
        }
    }
    
    private func removeCollapseButton(offsetFromBottom constant: CGFloat) {
        showButton.removeFromSuperview()
        //dividerLineView.removeFromSuperview()
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: constant).activate()
    }
    
    private func addFeatures(_ stringFeatures: [String], isPremium: Bool = true) {
        for feature in stringFeatures {
            let label = UILabel()
            label.text = feature
            label.font = isPremium ? .appFont(.bold, size: 12) : .appFont(.regular, size: 12)
            label.textColor = isPremium ? ColorConstants.cardBorderOrange : ColorConstants.darkText
            label.textAlignment = .left
            label.numberOfLines = 0
            stackView.addArrangedSubview(label)
            label.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16).activate()
            label.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -16).activate()
        }
    }
    
    private func hideFeatures() {
        stackView.arrangedSubviews
            .forEach {
                stackView.removeArrangedSubview($0)
                $0.removeFromSuperview()
        }
    }
    
    @objc private func onPurchaseTap(_ sender: UIButton) {
        guard let index = index else {
            return
        }
        delegate?.didPressSubscriptionPlanButton(planIndex: index, storageOfferType: storageOfferType)
    }
    
    @objc private func onCollapseTap(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        if sender.isSelected {
            switch features {
            case .recommended, .premiumOnly:
                ///expanded by default
                break
                
            case .features(let features):
                addFeatures([TextConstants.featureStandardFeatures])
                addFeatures(features.map({ $0.description }), isPremium: true)
            case .middleFeatures:
                let redactedFeatures = [TextConstants.featureHighQualityPicture,
                                        TextConstants.featureImageRecognition,
                                        TextConstants.middleUserPackageDescription,
                                        TextConstants.featureDeleteDuplicationContacts]
                addFeatures(redactedFeatures, isPremium: false)
            case .storageOnly:
                let redactedFeatures = [TextConstants.featureHighQualityPicture,
                                        TextConstants.featureImageRecognition,
                                        TextConstants.featurePhotopick,
                                        TextConstants.featureDeleteDuplicationContacts,
                                        TextConstants.featureStorageOnlyAdditional1,
                                        TextConstants.featureStorageOnlyAdditional2]
                addFeatures(redactedFeatures, isPremium: false)
            }
        } else {
            hideFeatures()
        }
    }
}
