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
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 18)
        }
    }
    
    @IBOutlet private weak var facebookTagsAllowedLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.facebookPhotoTags
            newValue.textColor = ColorConstants.darkText
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 18)
        }
    }
    
    @IBOutlet private weak var firstFacebookLabel: UILabel! {
        willSet {
            newValue.text = " "
            newValue.textColor = ColorConstants.darkText
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 15)
        }
    }
    
    @IBOutlet private weak var secondFacebookLabel: UILabel! {
        willSet {
            newValue.text = " "
            newValue.textColor = ColorConstants.darkText
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 15)
        }
    }
    
    @IBOutlet private weak var firstFaceImageLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.darkText
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 15)
            newValue.text = TextConstants.faceImageGroupingDescription
        }
    }
    
    @IBOutlet private weak var secondFaceImageLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.darkText
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 15)
            newValue.text = TextConstants.faceImageUpgrade
        }
    }
    
    @IBOutlet private weak var threeFaceImageLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.darkText
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 15)
            newValue.text = TextConstants.faceTagsDescriptionStandart
        }
    }
    
    @IBOutlet private weak var facebookImportButton: UIButton! {
        willSet {
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.backgroundColor = ColorConstants.darkBlueColor
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.layer.cornerRadius = 25
            newValue.setTitle(TextConstants.importFromFB, for: .normal)
        }
    }
    
    @IBOutlet private weak var faceImagePremiumButton: UIButton! {
        willSet {
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.setTitle(TextConstants.becomePremiumMember, for: .normal)
            newValue.titleEdgeInsets = UIEdgeInsetsMake(6, 17, 6, 17)
        }
    }
}
