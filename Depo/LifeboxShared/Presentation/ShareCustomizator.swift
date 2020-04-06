//
//  ShareCustomizator.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 2/26/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class ShareCustomizator: NSObject {
    
    @IBOutlet private weak var mainView: UIView! {
        didSet {
            mainView.backgroundColor = ColorConstants.searchShadowColor.withAlphaComponent(0.49)
        }
    }
    
    @IBOutlet private weak var cancelButton: UIButton! {
        didSet {
            cancelButton.isExclusiveTouch = true
            cancelButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
            cancelButton.setTitleColor(ColorConstants.lightText, for: .normal)
            cancelButton.setTitleColor(ColorConstants.darkText, for: .highlighted)
            cancelButton.setTitle(TextConstants.cancel, for: .normal)
        }
    }
    
    @IBOutlet private weak var uploadButton: UIButton! {
        didSet {
            uploadButton.isExclusiveTouch = true
            uploadButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
            uploadButton.setTitleColor(ColorConstants.blueColor, for: .normal)
            uploadButton.setTitleColor(ColorConstants.blueColor.darker(), for: .highlighted)
            uploadButton.setTitle(TextConstants.upload, for: .normal)
        }
    }
    
    @IBOutlet private weak var lineView: UIView! {
        didSet {
            lineView.backgroundColor = ColorConstants.blueColor
        }
    }
    
    @IBOutlet private weak var currentNameLabel: UILabel! {
        didSet {
            currentNameLabel.font = UIFont.TurkcellSaturaDemFont(size: 20)
            currentNameLabel.textColor = ColorConstants.darkText
            currentNameLabel.text = " "
        }
    }
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.setLayout(itemSize: CGSize(width: 40, height: 40), lineSpacing: 1, itemSpacing: 0)
        }
    }
    
    @IBOutlet private weak var uploadProgress: UIProgressView! {
        didSet {
            uploadProgress.trackTintColor = ColorConstants.lightGrayColor
            uploadProgress.progressTintColor = ColorConstants.greenColor
            uploadProgress.progress = 0
        }
    }
    
    @IBOutlet private weak var progressLabel: UILabel! {
        didSet {
            progressLabel.font = UIFont.TurkcellSaturaRegFont(size: 20)
            progressLabel.textColor = ColorConstants.blueColor
            progressLabel.text = " "
        }
    }
    
    @IBOutlet private weak var currentPhotoImageView: UIImageView! {
        didSet {
            currentPhotoImageView.backgroundColor = UIColor.lightGray
        }
    }
}
