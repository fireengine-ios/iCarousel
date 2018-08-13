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
    
    func applyConfiguration(_ configuration: FaceImageDisplayConfigurations) {
        switch configuration {
        case .initial:
            labelsStackView.isHidden = true
            facebookView.isHidden = true
            facebookImportButton.isHidden = true
            /// face image switch is off
            /// hide all
            
        case .facebookTagsOff:
            labelsStackView.isHidden = false
            facebookView.isHidden = false
            facebookImportButton.isHidden = true
            firstFacebookLabel.text = "505"
            secondFacebookLabel.isHidden = true
            /// facebook switch is off
            /// show one texts
            
        case .facebookImportOff:
            labelsStackView.isHidden = false
            facebookView.isHidden = false
            facebookImportButton.isHidden = false
            firstFacebookLabel.text = "503"
            secondFacebookLabel.isHidden = false
            secondFacebookLabel.text = "504"
            /// face image switch is on
            /// facebook switch is on
            /// show button and two texts
            
        case .facebookImportOn:
            labelsStackView.isHidden = false
            facebookView.isHidden = false
            facebookImportButton.isHidden = true
            firstFacebookLabel.text = "503"
            secondFacebookLabel.isHidden = true
            /// face image switch is on
            /// facebook switch is on
            /// hide button and second text
        }
    }
}
