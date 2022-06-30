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
            newValue.textColor = ColorConstants.darkText
            newValue.font = .appFont(.regular, size: 18)
        }
    }
    
    @IBOutlet private weak var facebookTagsAllowedLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.facebookPhotoTags
            newValue.textColor = ColorConstants.darkText
            newValue.font = .appFont(.regular, size: 18)
        }
    }
    
    @IBOutlet private weak var firstFacebookLabel: UILabel! {
        willSet {
            newValue.text = " "
            newValue.textColor = ColorConstants.darkText
            newValue.font = .appFont(.regular, size: 15)
        }
    }
    
    @IBOutlet private weak var secondFacebookLabel: UILabel! {
        willSet {
            newValue.text = " "
            newValue.textColor = ColorConstants.darkText
            newValue.font = .appFont(.regular, size: 15)
        }
    }
    
    @IBOutlet private weak var firstFaceImageLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.darkText
            newValue.font = .appFont(.regular, size: 15)
            newValue.text = TextConstants.faceImageGroupingDescription
        }
    }
    
    @IBOutlet private weak var secondFaceImageLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.darkText
            newValue.font = .appFont(.regular, size: 15)
            newValue.text = TextConstants.faceImageUpgrade
        }
    }
    
    @IBOutlet private weak var threeFaceImageLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.darkText
            newValue.font = .appFont(.regular, size: 15)
            newValue.text = TextConstants.faceTagsDescriptionStandart
        }
    }
    
    @IBOutlet private weak var facebookImportButton: UIButton! {
        willSet {
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.backgroundColor = ColorConstants.darkBlueColor
            newValue.titleLabel?.font = .appFont(.bold, size: 18)
            newValue.layer.cornerRadius = 25
            newValue.setTitle(TextConstants.importFromFB, for: .normal)
        }
    }
    
    @IBOutlet private weak var faceImagePremiumButton: UIButton! {
        willSet {
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.titleLabel?.font = .appFont(.bold, size: 18)
            newValue.setTitle(TextConstants.becomePremiumMember, for: .normal)
            newValue.titleEdgeInsets = UIEdgeInsets(top: 6, left: 17, bottom: 6, right: 17)
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
    
    
}
