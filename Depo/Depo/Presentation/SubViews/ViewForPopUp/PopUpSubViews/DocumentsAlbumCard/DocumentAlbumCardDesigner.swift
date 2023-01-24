//
//  DocumentAlbumCardDesigner.swift
//  Depo
//
//  Created by Maxim Soldatov on 4/20/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class DocumentAlbumCardDesigner: NSObject {
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 16)
            newValue.textColor = AppColor.label.color
            newValue.text = TextConstants.documentsAlbumCardTitleLabel
        }
    }
    
    @IBOutlet private weak var imagesStackView: UIStackView! {
        willSet {
            newValue.spacing = 4
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.light, size: 14)
            newValue.textColor = AppColor.label.color
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var hideDocumentsButton: UIButton! {
        willSet {
            newValue.titleLabel?.font = .appFont(.bold, size: 14)
            newValue.setTitleColor(AppColor.settingsButtonColor.color, for: .normal)
            newValue.setTitle(TextConstants.documentsAlbumCardHideButton, for: .normal)
        }
    }
    
    @IBOutlet private weak var viewDocumentsButton: UIButton! {
        willSet {
            newValue.titleLabel?.font = .appFont(.bold, size: 14)
            newValue.setTitleColor(AppColor.settingsButtonColor.color, for: .normal)
            newValue.setTitle(TextConstants.documentsAlbumCardViewButton, for: .normal)
        }
    }
}
