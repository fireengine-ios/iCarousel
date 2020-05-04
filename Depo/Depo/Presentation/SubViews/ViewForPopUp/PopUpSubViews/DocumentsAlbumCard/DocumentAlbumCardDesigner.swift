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
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.textColor = ColorConstants.darkText
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
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 18)
            newValue.textColor = ColorConstants.textGrayColor
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var separatorView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.placeholderGrayColor
        }
    }
    
    @IBOutlet private weak var hideDocumentsButton: UIButton! {
        willSet {
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
            newValue.setTitleColor(ColorConstants.blueColor, for: .normal)
            newValue.setTitle(TextConstants.documentsAlbumCardHideButton, for: .normal)
        }
    }
    
    @IBOutlet private weak var viewDocumentsButton: UIButton! {
        willSet {
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
            newValue.setTitleColor(ColorConstants.blueColor, for: .normal)
            newValue.setTitle(TextConstants.documentsAlbumCardViewButton, for: .normal)
        }
    }
}
