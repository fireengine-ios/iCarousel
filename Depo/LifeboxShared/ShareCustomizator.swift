//
//  ShareCustomizator.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 2/26/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class ShareCustomizator: NSObject {
    @IBOutlet private weak var cancelButton: UIButton! {
        didSet {
            cancelButton.isExclusiveTouch = true
            cancelButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
            cancelButton.setTitleColor(ColorConstants.lightText, for: .normal)
            cancelButton.setTitleColor(ColorConstants.darkText, for: .highlighted)
            cancelButton.setTitle("Cancel", for: .normal)
        }
    }
    @IBOutlet private weak var uploadButton: UIButton! {
        didSet {
            uploadButton.isExclusiveTouch = true
            uploadButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
            uploadButton.setTitleColor(ColorConstants.blueColor, for: .normal)
            uploadButton.setTitleColor(ColorConstants.blueColor.darker(), for: .highlighted)
            uploadButton.setTitle("Upload", for: .normal)
        }
    }
    @IBOutlet private weak var lineView: UIView! {
        didSet {
            lineView.backgroundColor = ColorConstants.blueColor
        }
    }
    @IBOutlet private weak var mainView: UIView! {
        didSet {
            mainView.backgroundColor = ColorConstants.searchShadowColor
        }
    }
}
