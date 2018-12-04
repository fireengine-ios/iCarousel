//
//  FaceImageDisplayManager.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 8/10/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

enum FaceImageDisplayConfigurations {
    case initial /// faceImageOff
    case faceImageOn
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
    @IBOutlet private weak var faceImagePremiumButton: GradientPremiumButton!
    @IBOutlet private weak var faceImageView: UIView!
    
    var configuration = FaceImageDisplayConfigurations.initial
    
    func applyConfiguration(_ configuration: FaceImageDisplayConfigurations) {
        self.configuration = configuration
        
        switch configuration {
        case .initial:
            labelsStackView.isHidden = true
            facebookView.isHidden = true
            facebookImportButton.isHidden = true
            faceImageStackView.isHidden = true
            firstFaceImageLabel.isHidden = true
            secondFaceImageLabel.isHidden = true
            faceImagePremiumButton.isHidden = true
            faceImageView.isHidden = true
            /// face image switch is off
            /// hide all
        case .faceImageOn:
            faceImageStackView.isHidden = false
            firstFaceImageLabel.isHidden = false
            secondFaceImageLabel.isHidden = false
            faceImagePremiumButton.isHidden = false
            faceImageView.isHidden = false
        case .facebookTagsOff:
            labelsStackView.isHidden = false
            facebookView.isHidden = false
            facebookImportButton.isHidden = true
            firstFacebookLabel.text = TextConstants.facebookTagsOff
            secondFacebookLabel.isHidden = true
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
            /// facebook switch is on
            /// show button and two texts
            
        case .facebookImportOn:
            labelsStackView.isHidden = false
            facebookView.isHidden = false
            facebookImportButton.isHidden = true
            firstFacebookLabel.text = TextConstants.facebookTagsOn
            secondFacebookLabel.isHidden = true
            /// face image switch is on
            /// facebook switch is on
            /// hide button and second text
        }
    }
}
