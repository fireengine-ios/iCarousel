//
//  HighlightPackage.swift
//  Lifebox
//
//  Created by Ozan Salman on 4.11.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import UIKit

final class HighlightPackage: BaseCardView {
    
    @IBOutlet weak var titleLabel: UILabel! {
        willSet {
            newValue.text = "Fırsatı Kaçırma"
            newValue.font = .appFont(.medium, size: 16)
        }
    }
    
    @IBOutlet weak var iconImageView: UIImageView! {
        willSet {
            newValue.image = Image.iconBottomSheetConfetti.image
        }
    }
    
    @IBOutlet weak var contentView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 16
        }
    }
    
    @IBOutlet weak var packageTitleName: UILabel! {
        willSet {
            newValue.text = localized(.higlightedPackageRecommended)
            newValue.font = .appFont(.medium, size: 14)
        }
    }
    
    @IBOutlet weak var promoLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.bold, size: 14)
        }
    }
    
    @IBOutlet weak var packageContentView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 16
            newValue.backgroundColor = .white
        }
    }
    
    @IBOutlet weak var quotaLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.highlightColor.color
            newValue.font = .appFont(.medium, size: 14)
        }
    }
    
    @IBOutlet weak var priceLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.highlightColor.color
            newValue.font = .appFont(.medium, size: 14)
        }
    }
    
    @IBOutlet weak var storageLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.highlightColor.color
            newValue.font = .appFont(.medium, size: 12)
        }
    }
    
    @IBOutlet weak var pruchaseButton: DarkBlueButton! {
        willSet {
            newValue.setTitle(TextConstants.purchase, for: .normal)
        }
    }
    
    private var packageIndex: Int = 0
    private var highlightedOffer: SubscriptionPlan?
    
    override func configurateView() {
        super.configurateView()
        
        canSwipe = false
        
        titleLabel.font = .appFont(.medium, size: 16)
        titleLabel.textColor = AppColor.label.color

        addGradient()
    }
    
    func configurateWithType(item: SubscriptionPlan?) {
        let storageVars: StorageVars = factory.resolve()
        self.highlightedOffer = item
        self.packageIndex = storageVars.discoverHighlightIndex
        let model = item?.model as? PackageModelResponse
        promoLabel.text = model?.displayName
        quotaLabel.text = item?.name
        priceLabel.text = item?.price
        storageLabel.text = SubscriptionPlan.AddonType.makeTextByAddonType(addonType: item?.addonType ?? .storageOnly)        
    }

    override func viewWillShow() {
        super.viewWillShow()

    }
    
    private func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = contentView.bounds;
        gradientLayer.colors = [AppColor.premiumThirdGradient.cgColor,
                                AppColor.premiumSecondGradient.cgColor,
                                AppColor.premiumFirstGradient.cgColor]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        contentView.layer.insertSublayer(gradientLayer, at: 0);
    }
    
    @IBAction func onPruchaseButtonTap(_ sender: Any) {
        let router = RouterVC()
        router.pushViewController(viewController: router.myStorage(usageStorage: nil, affiliate: "highlighted"))
    }
    
    
}
