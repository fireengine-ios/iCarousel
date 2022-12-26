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
            cancelButton.titleLabel?.font = .appFont(.medium, size: 14)
            cancelButton.setTitleColor(AppColor.darkBlue.color, for: .normal)
            cancelButton.setTitle(TextConstants.cancel, for: .normal)
        }
    }
    
    @IBOutlet private weak var uploadButton: UIButton! {
        didSet {
            uploadButton.isExclusiveTouch = true
            uploadButton.titleLabel?.font = .appFont(.medium, size: 14)
            uploadButton.setTitleColor(AppColor.darkBlue.color, for: .normal)
            uploadButton.setTitle(TextConstants.upload, for: .normal)
        }
    }
    
    @IBOutlet private weak var lineView: UIView! {
        didSet {
            lineView.backgroundColor = AppColor.darkBlueColor.color
        }
    }
    
    @IBOutlet private weak var currentNameLabel: UILabel! {
        didSet {
            currentNameLabel.font = .appFont(.medium, size: 20)
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
            uploadProgress.progressTintColor = ColorConstants.darkBlueColor
            uploadProgress.progress = 0
        }
    }
    
    @IBOutlet private weak var progressLabel: UILabel! {
        didSet {
            progressLabel.font = .appFont(.medium, size: 18)
            progressLabel.textColor = AppColor.darkBlue.color
            progressLabel.text = " "
        }
    }
    
    @IBOutlet private weak var currentPhotoImageView: UIImageView! {
        didSet {
            currentPhotoImageView.backgroundColor = UIColor.lightGray
        }
    }
}
