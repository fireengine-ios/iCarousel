//
//  InstaPickCampaignViewControllerDesigner.swift
//  Depo
//
//  Created by Maxim Soldatov on 10/22/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class InstaPickCampaignViewControllerDesigner: NSObject {
    
    private let cornerRadiusForViews: CGFloat = 8
    private let cornerRadiusForContentView: CGFloat = 2
    
    @IBOutlet weak var backgroundView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.backgroundViewColor
        }
    }
    
    @IBOutlet private weak var scrollView: UIScrollView! {
        willSet {
            newValue.backgroundColor = ColorConstants.blueColor
            newValue.layer.cornerRadius = cornerRadiusForContentView
            newValue.layer.masksToBounds = true
        }
    }
    
    @IBOutlet private weak var contentView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.blueColor
            newValue.layer.cornerRadius = cornerRadiusForContentView
            newValue.layer.masksToBounds = true
        }
    }
    
    //MARK: TopView
    
    @IBOutlet private weak var topView: UIView! {
        willSet {
            newValue.layer.cornerRadius = cornerRadiusForViews
            newValue.layer.masksToBounds = true
            newValue.backgroundColor = AppColor.secondaryBackground.color
        }
    }
        
    @IBOutlet private weak var topViewTitleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.textColor = ColorConstants.darkText
            newValue.numberOfLines = 2
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet private weak var topViewDescriptionLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 16)
            newValue.textColor = ColorConstants.textGrayColor
        }
    }
    
    @IBOutlet private weak var topViewButtonView: UIView! {
        willSet {
            newValue.backgroundColor = .clear
        }
    }
    
    @IBOutlet private weak var topViewPremiumButton: GradientPremiumButton! {
        willSet {
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 16)
            newValue.setTitle(TextConstants.campaignViewControllerBecomePremium, for: .normal)
            newValue.titleEdgeInsets = UIEdgeInsets(top: 6, left: 17, bottom: 6, right: 17)
        }
    }
    
    //MARK: BottomView
    
    @IBOutlet private weak var bottomView: UIView! {
        willSet {
            newValue.layer.cornerRadius = cornerRadiusForViews
            newValue.layer.masksToBounds = true
            newValue.backgroundColor = AppColor.secondaryBackground.color
        }
    }
    
    @IBOutlet private weak var bottomViewTitleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.textColor = ColorConstants.textGrayColor
        }
    }
    
    @IBOutlet private weak var bottomViewDescriptionLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 16)
            newValue.textColor = ColorConstants.textGrayColor
        }
    }
    
    @IBOutlet private weak var bottomViewEditProfileButton: RoundedButton! {
        willSet {
            newValue.setTitle(TextConstants.campaignViewControllerEditProfileButton, for: .normal)
            newValue.setTitleColor(AppColor.lrTealishAndWhite.color, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.layer.borderColor = ColorConstants.blueColor.cgColor
            newValue.layer.borderWidth = 1
            newValue.isOpaque = true
        }
    }
    
    //MARK: ContentView
    @IBOutlet private weak var showResultButton: BlueButtonWithMediumWhiteText! {
        willSet {
            newValue.setTitle(TextConstants.campaignViewControllerShowResultButton, for: .normal)
            newValue.setBackgroundColor(ColorConstants.darkBlueColor, for: .normal)
        }
    }
}
