//
//  FaceImageDisplayManager.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 8/10/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

//struct FaceImageVisibleConfiguration {
//    let isHiddenFacebookView: Bool
//    let isHiddenLabelsStackView: Bool
//    let isHiddenFacebookImportButton: Bool
//    let isHiddenFirstFacebookLabel: Bool
//    let isHiddenSecondFacebookLabel: Bool
//}
//extension FaceImageVisibleConfiguration {
//    static var initial: FaceImageVisibleConfiguration {
//        return FaceImageVisibleConfiguration(
//            isHiddenFacebookView: true,
//            isHiddenLabelsStackView: true,
//            isHiddenFacebookImportButton: true,
//            isHiddenFirstFacebookLabel: true,
//            isHiddenSecondFacebookLabel: true)
//    }
//}

enum FaceImageDisplayConfigurations {
    case initial
}

protocol FaceImageDisplayConfiguration {
    func applyFor(facebookView: UIView,
                  labelsStackView: UIStackView,
                  facebookImportButton: UIButton,
                  firstFacebookLabel: UILabel,
                  secondFacebookLabel: UILabel)
}

final class FaceImageDisplayConfigurationInitial: FaceImageDisplayConfiguration {
    func applyFor(facebookView: UIView,
                  labelsStackView: UIStackView,
                  facebookImportButton: UIButton,
                  firstFacebookLabel: UILabel,
                  secondFacebookLabel: UILabel) {
        
        labelsStackView.isHidden = true
        facebookView.isHidden = true
        facebookImportButton.isHidden = true
    }
}

final class FaceImageDisplayManager: NSObject {
    
    @IBOutlet private weak var facebookView: UIView!
    @IBOutlet private weak var labelsStackView: UIStackView!
    @IBOutlet private weak var facebookImportButton: UIButton!
    @IBOutlet private weak var firstFacebookLabel: UILabel!
    @IBOutlet private weak var secondFacebookLabel: UILabel!
    
//    func applyVisibleConfiguration(_ configuration: FaceImageVisibleConfiguration) {
//        facebookView.isHidden = configuration.isHiddenFacebookView
//        labelsStackView.isHidden = configuration.isHiddenLabelsStackView
//        facebookImportButton.isHidden = configuration.isHiddenFacebookImportButton
//        firstFacebookLabel.isHidden = configuration.isHiddenFirstFacebookLabel
//        secondFacebookLabel.isHidden = configuration.isHiddenSecondFacebookLabel
//    }
    
    func applyConfiguration(_ configuration: FaceImageDisplayConfiguration) {
        configuration.applyFor(facebookView: facebookView,
                               labelsStackView: labelsStackView,
                               facebookImportButton: facebookImportButton,
                               firstFacebookLabel: firstFacebookLabel,
                               secondFacebookLabel: secondFacebookLabel)
    }
    
    func applyConfiguration(_ configuration: FaceImageDisplayConfigurations) {
        switch configuration {
        case .initial:
            applyConfiguration(FaceImageDisplayConfigurationInitial())
        }
    }
}
