//
//  FaceImageDesigner.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 8/13/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class FaceImageDesigner: NSObject {
    
    @IBOutlet private weak var faceImageAllowedLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.faceImageGrouping
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.regular, size: 14)
        }
    }
    
    @IBOutlet private weak var facebookTagsAllowedLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.facebookPhotoTags
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.regular, size: 14)
        }
    }
    
    @IBOutlet private weak var firstFacebookLabel: UILabel! {
        willSet {
            newValue.text = " "
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.regular, size: 12)
        }
    }
    
    @IBOutlet private weak var secondFacebookLabel: UILabel! {
        willSet {
            newValue.text = " "
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.regular, size: 12)
        }
    }
    
    @IBOutlet private weak var firstFaceImageLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.regular, size: 12)
            newValue.text = TextConstants.faceImageGroupingDescription
        }
    }
    
    @IBOutlet private weak var secondFaceImageLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.regular, size: 12)
            newValue.text = TextConstants.faceImageUpgrade
        }
    }
    
    @IBOutlet private weak var threeFaceImageLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.regular, size: 12)
            newValue.text = TextConstants.faceTagsDescriptionStandart
        }
    }
    
    @IBOutlet private weak var facebookImportButton: UIButton! {
        willSet {
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.backgroundColor = ColorConstants.darkBlueColor
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
            newValue.layer.cornerRadius = 25
            newValue.setTitle(TextConstants.importFromFB, for: .normal)
        }
    }
    
    @IBOutlet private weak var faceImagePremiumButton: UIButton! {
        willSet {
            newValue.setTitleColor(AppColor.premiumGradientLabel.color, for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
            newValue.setTitle(TextConstants.becomePremiumMember, for: .normal)
            newValue.titleEdgeInsets = UIEdgeInsets(top: 6, left: 17, bottom: 6, right: 17)
            newValue.alpha = 0.85
        }
    }
    
    
    @IBOutlet weak var faceImageBackView: UIView! {
        willSet {
            newValue.addRoundedShadows(cornerRadius: 16,
                                       shadowColor: AppColor.viewShadowLight.cgColor,
                                       opacity: 0.8, radius: 6.0)
            newValue.backgroundColor = AppColor.secondaryBackground.color

        }
    }
    
    
    @IBOutlet weak var facebookImageBackView: UIView! {
        willSet {
            newValue.addRoundedShadows(cornerRadius: 16,
                                       shadowColor: AppColor.viewShadowLight.cgColor,
                                       opacity: 0.8, radius: 6.0)
            newValue.backgroundColor = AppColor.secondaryBackground.color
        }
    }
    
    @IBOutlet private weak var faceImageTopView: UIView! {
        willSet {
            newValue.backgroundColor = AppColor.secondaryBackground.color
            newValue.addRoundedShadows(cornerRadius: 16, shadowColor: AppColor.drawerShadow.cgColor, opacity: 0.3, radius: 8, offset: CGSize(width: 0, height: 4))
        }
    }
    
    @IBOutlet private weak var facebookTopView: UIView! {
        willSet {
            newValue.backgroundColor = AppColor.secondaryBackground.color
            newValue.addRoundedShadows(cornerRadius: 16, shadowColor: AppColor.drawerShadow.cgColor, opacity: 0.3, radius: 8, offset: CGSize(width: 0, height: 4))
        }
    }
    
}
