//
//  CampaignCardDesigner.swift
//  Depo
//
//  Created by Maxim Soldatov on 10/18/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class CampaignCardDesigner: NSObject {
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.textColor = ColorConstants.darkText
            newValue.text = TextConstants.campaignCardTitle
        }
    }
    
    @IBOutlet private weak var separatorView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.placeholderGrayColor
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 18)
            newValue.textColor = ColorConstants.textGrayColor
        }
    }
    
    @IBOutlet private weak var campaignDetailButton: UIButton! {
        willSet {
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
            newValue.setTitleColor(ColorConstants.blueColor, for: .normal)
            newValue.setTitle(TextConstants.campaignDetailButtonTitle, for: .normal)
        }
    }
    
    @IBOutlet private weak var analyzeDetailButton: UIButton! {
        willSet {
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
            newValue.setTitleColor(ColorConstants.blueColor, for: .normal)
            newValue.setTitle(TextConstants.analyzePhotoPickButtonTitle, for: .normal)
        }
    }
}
