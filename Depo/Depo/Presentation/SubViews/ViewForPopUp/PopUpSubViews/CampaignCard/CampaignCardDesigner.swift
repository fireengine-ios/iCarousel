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
            newValue.font = .appFont(.medium, size: 16)
            newValue.textColor = AppColor.label.color
            newValue.text = TextConstants.campaignCardTitle
        }
    }
    
    @IBOutlet private weak var separatorView: UIView! {
        willSet {
            newValue.backgroundColor = AppColor.settingsButtonColor.color
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 14)
            newValue.textColor = AppColor.label.color
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var campaignDetailButton: UIButton! {
        willSet {
            newValue.titleLabel?.font = .appFont(.bold, size: 14)
            newValue.setTitleColor(AppColor.settingsButtonColor.color, for: .normal)
            newValue.setTitle("", for: .normal)
        }
    }
    
    @IBOutlet private weak var analyzeDetailButton: UIButton! {
        willSet {
            newValue.titleLabel?.font = .appFont(.bold, size: 14)
            newValue.setTitleColor(AppColor.settingsButtonColor.color, for: .normal)
            newValue.setTitle(TextConstants.analyzePhotoPickButtonTitle, for: .normal)
        }
    }
    
    @IBOutlet private weak var playVideoButton: UIButton! {
        willSet {
            newValue.isHidden = true
        }
    }
}
