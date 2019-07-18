//
//  FaceImageDisplayManager.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 8/10/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

enum FaceImageDisplayConfigurations {
    case initialStandart /// faceImageOff
    case initialPremium
    case faceImageStandart
    case faceImagePremium
    case facebookTagsOff
    case facebookImportOff
    case facebookImportOn
}

final class FaceImageDisplayManager: NSObject {
    
    @IBOutlet private weak var facebookView: UIView!
    @IBOutlet private weak var labelsStackView: UIStackView!
    @IBOutlet private weak var facebookImportButton: UIButton!
    @IBOutlet private weak var firstFacebookLabel: UILabel!
    @IBOutlet private weak var secondFacebookLabel: UILabel!
    @IBOutlet private weak var faceImageStackView: UIStackView!
    @IBOutlet private weak var firstFaceImageLabel: UILabel!
    @IBOutlet private weak var secondFaceImageLabel: UILabel!
    @IBOutlet private weak var threeFaceImageLabel: UILabel!
    @IBOutlet private weak var faceImagePremiumButton: GradientPremiumButton!
    @IBOutlet private weak var faceImageView: UIView!
    
    var configuration = FaceImageDisplayConfigurations.initialStandart
    
    func applyConfiguration(_ configuration: FaceImageDisplayConfigurations) {
        self.configuration = configuration
        
        switch configuration {
        case .initialStandart:
            labelsStackView.isHidden = true
            facebookView.isHidden = true
            facebookImportButton.isHidden = true
            faceImageStackView.isHidden = false
            firstFaceImageLabel.isHidden = true
            secondFaceImageLabel.isHidden = true
            threeFaceImageLabel.isHidden = false
            threeFaceImageLabel.text = TextConstants.faceTagsDescriptionStandart
            faceImagePremiumButton.isHidden = true
            faceImageView.isHidden = true
            /// face image switch is off
            /// hide all
        
        case .initialPremium:
            labelsStackView.isHidden = true
            facebookView.isHidden = true
            facebookImportButton.isHidden = true
            faceImageStackView.isHidden = false
            firstFaceImageLabel.isHidden = true
            secondFaceImageLabel.isHidden = true
            threeFaceImageLabel.isHidden = false
            threeFaceImageLabel.text = TextConstants.faceTagsDescriptionPremium
            faceImagePremiumButton.isHidden = true
            faceImageView.isHidden = true
            /// face image switch is off
            /// hide all
            
        case .faceImageStandart:
            faceImageStackView.isHidden = false
            firstFaceImageLabel.isHidden = false
            secondFaceImageLabel.isHidden = false
            faceImagePremiumButton.isHidden = false
            faceImageView.isHidden = false
            /// face image switch is on
            /// StandartUser
            
        case .faceImagePremium:
            faceImageStackView.isHidden = false
            firstFaceImageLabel.isHidden = true
            secondFaceImageLabel.isHidden = true
            threeFaceImageLabel.isHidden = false
            threeFaceImageLabel.text = TextConstants.faceTagsDescriptionPremium
            faceImagePremiumButton.isHidden = true
            faceImageView.isHidden = true
            /// face image switch is on
            /// PremiumUser
            
        case .facebookTagsOff:
            labelsStackView.isHidden = false
            facebookView.isHidden = false
            firstFacebookLabel.text = TextConstants.facebookTagsOff
            secondFacebookLabel.isHidden = true
            facebookImportButton.isHidden = true
            /// facebook switch is off
            /// show one text
            
        case .facebookImportOff:
            labelsStackView.isHidden = false
            facebookView.isHidden = false
            facebookImportButton.isHidden = false
            firstFacebookLabel.text = TextConstants.facebookTagsOn
            secondFacebookLabel.isHidden = false
            secondFacebookLabel.text = TextConstants.facebookTagsImport
            /// face image switch is on
            /// facebook switch is off
            /// show button and two texts
            
        case .facebookImportOn:
            labelsStackView.isHidden = false
            facebookView.isHidden = false
            firstFacebookLabel.text = TextConstants.facebookTagsOn
            facebookImportButton.isHidden = true
            secondFacebookLabel.isHidden = true
            /// face image switch is on
            /// facebook switch is on
            /// hide button and second text
        }
    }
}
