//
//  HighlightedPackageView.swift
//  Depo
//
//  Created by Ozan Salman on 1.11.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

protocol HighlightedPackageBannerDelegate: AnyObject {
    func buyHighlightedPackage()
}

class HighlightedPackageView: UIView {
    
    lazy var containerView: UIView = {
        let screenSize: CGRect = UIScreen.main.bounds
        let cv = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 209))
        cv.backgroundColor = UIColor(white: 1, alpha: 0)
        cv.clipsToBounds = false
        return cv
    }()
    
    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.text = "Önerilen"
        view.textColor = .white
        view.font = .appFont(.medium, size: 14)
        view.numberOfLines = 0
        return view
    }()
    
    lazy var promoLabel: UILabel = {
        let view = UILabel()
        view.text = "İlk 1 ay ücretsiz"
        view.textColor = .white
        view.font = .appFont(.medium, size: 14)
        view.numberOfLines = 0
        view.sizeToFit()
        return view
    }()
    
    lazy var contentView: UIView = {
        let cv = UIView()
        cv.backgroundColor = .white
        cv.clipsToBounds = false
        cv.layer.cornerRadius = 16
        return cv
    }()
    
    lazy var quotaLabel: UILabel = {
        let view = UILabel()
        view.textColor = AppColor.highlightColor.color
        view.font = .appFont(.medium, size: 14)
        view.numberOfLines = 0
        view.sizeToFit()
        return view
    }()
    
    lazy var priceLabel: UILabel = {
        let view = UILabel()
        view.textColor = AppColor.darkLabel.color
        view.font = .appFont(.medium, size: 14)
        view.numberOfLines = 0
        view.sizeToFit()
        return view
    }()
    
    lazy var storageLabel: UILabel = {
        let view = UILabel()
        view.textColor = AppColor.highlightColor.color
        view.font = .appFont(.medium, size: 12)
        view.numberOfLines = 0
        view.sizeToFit()
        return view
    }()
    
    lazy var purchaseButton: DarkBlueButton = {
        let view = DarkBlueButton()
        view.setTitle(TextConstants.purchase, for: .normal)
        return view
    }()
    
    weak var delegate: HighlightedPackageBannerDelegate?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        addGradient()
    
        purchaseButton.addTarget(self, action: #selector(purchaseButtonAction), for: .touchUpInside)
        clipsToBounds = true
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
        addGradient()
    }
    
    private func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = containerView.layer.bounds;
        gradientLayer.colors = [AppColor.premiumThirdGradient.cgColor,
                                AppColor.premiumSecondGradient.cgColor,
                                AppColor.premiumFirstGradient.cgColor]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
        containerView.layer.insertSublayer(gradientLayer, at: 0);
    }
    
    private func setupLayout() {
        
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: topAnchor).activate()
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor).activate()
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor).activate()
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).activate()
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16).activate()
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).activate()
        titleLabel.widthAnchor.constraint(equalToConstant: 100).activate()
        titleLabel.heightAnchor.constraint(equalToConstant: 24).activate()
        
        addSubview(promoLabel)
        promoLabel.translatesAutoresizingMaskIntoConstraints = false
        promoLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16).activate()
        promoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).activate()
        promoLabel.heightAnchor.constraint(equalToConstant: 24).activate()
        
        containerView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16).activate()
        contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).activate()
        contentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).activate()
        contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16).activate()
        
        contentView.addSubview(quotaLabel)
        quotaLabel.translatesAutoresizingMaskIntoConstraints = false
        quotaLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).activate()
        quotaLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).activate()
        quotaLabel.heightAnchor.constraint(equalToConstant: 24).activate()
        quotaLabel.widthAnchor.constraint(equalToConstant: 120).activate()
        
        contentView.addSubview(priceLabel)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).activate()
        priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).activate()
        priceLabel.heightAnchor.constraint(equalToConstant: 24).activate()
        
        contentView.addSubview(storageLabel)
        storageLabel.translatesAutoresizingMaskIntoConstraints = false
        storageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40).activate()
        storageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).activate()
        storageLabel.heightAnchor.constraint(equalToConstant: 24).activate()
        storageLabel.widthAnchor.constraint(equalToConstant: 120).activate()
        
        contentView.addSubview(purchaseButton)
        purchaseButton.translatesAutoresizingMaskIntoConstraints = false
        purchaseButton.topAnchor.constraint(equalTo: storageLabel.bottomAnchor, constant: 16).activate()
        purchaseButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 44).activate()
        purchaseButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -44).activate()
        purchaseButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).activate()
        purchaseButton.heightAnchor.constraint(equalToConstant: 45).activate()
    }
    
    @objc private func purchaseButtonAction() {
        delegate?.buyHighlightedPackage()
    }
}
