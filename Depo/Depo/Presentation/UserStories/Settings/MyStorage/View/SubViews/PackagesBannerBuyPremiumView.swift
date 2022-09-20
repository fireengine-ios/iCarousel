//
//  PackagesBannerBuyPremiumView.swift
//  Lifebox
//
//  Created by yilmaz edis on 19.09.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol BuyPremiumBannerDelegate: AnyObject {
    func buyPremium()
}

class PackagesBannerBuyPremiumView: UIView {
    
    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.text = "Premuim ol bir sürü özelliğe sahip ol"
        view.textColor = .white
        view.font = .appFont(.medium, size: 14)
        view.numberOfLines = 0
        return view
    }()
    
    lazy var cancelButton: UIButton = {
        let view = UIButton()
        
        view.clipsToBounds = true
        view.adjustsFontSizeToFitWidth()
        view.setBackgroundImage(Image.settingsIconCancel.image, for: .normal)
        
        return view
    }()
    
    lazy var buyButton: RoundedInsetsButton = {
        let view = RoundedInsetsButton()
        
        view.clipsToBounds = true
        view.adjustsFontSizeToFitWidth()
        view.insets = UIEdgeInsets(topBottom: 8, rightLeft: 12)
        view.setTitle("Get Premium", for: .normal)
        view.setTitleColor(AppColor.settingsRestoreTextColor.color, for: .normal)
        view.backgroundColor = .white
        view.titleLabel?.font = .appFont(.medium, size: 16)
        view.layer.cornerRadius = 23
        
        return view
    }()
    
    let containerView: UIView = {
        let screenSize: CGRect = UIScreen.main.bounds
        let cv = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 137))
        cv.backgroundColor = UIColor(white: 1, alpha: 0)
        cv.clipsToBounds = false
        return cv
    }()
    
    lazy var backgroundView = GradientPremiumButton()
    
    weak var delegate: BuyPremiumBannerDelegate?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        addGradient()
        
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        buyButton.addTarget(self, action: #selector(buyButtonAction), for: .touchUpInside)
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
      
        addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 24).activate()
        cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).activate()
        cancelButton.heightAnchor.constraint(equalToConstant: 24).activate()
        cancelButton.widthAnchor.constraint(equalToConstant: 24).activate()
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24).activate()
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).activate()
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -56).activate()
        
        addSubview(buyButton)
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        buyButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).activate()
        buyButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).activate()
        buyButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).activate()
        buyButton.heightAnchor.constraint(equalToConstant: 45).activate()
    }
    
    @objc private func cancelButtonAction() {
        isHidden = true
    }
    
    @objc private func buyButtonAction() {
        delegate?.buyPremium()
    }
}
