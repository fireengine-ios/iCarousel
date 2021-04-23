//
//  EmptyDataView.swift
//  Depo
//
//  Created by Bondar Yaroslav on 8/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol EmptyDataViewDelegate: AnyObject {
    func didButtonTapped()
}

private extension GalleryViewType {
    
    var emptyViewMessage: String {
        switch self {
        case .all, .synced:
            return TextConstants.photosVideosViewNoPhotoTitleText
        case .unsynced:
            return TextConstants.photosVideosEmptyNoUnsyncPhotosTitle
        }
    }
    
    var emptyViewActionTitle: String? {
        switch self {
        case .all, .synced:
            return TextConstants.photosVideosViewNoPhotoButtonText
        case .unsynced:
            return nil
        }
    }
    
    var emptyViewImage: UIImage? {
        switch self {
        case .all, .synced:
            return UIImage(named: "ImageNoPhotos")
        case .unsynced:
            return nil
        }
    }
}

final class EmptyDataView: UIView, NibInit {
    weak var delegate: EmptyDataViewDelegate?
    
    @IBOutlet private weak var messageLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.textGrayColor.color
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 14)
        }
    }
    
    @IBOutlet private weak var iconImageView: UIImageView!
    
    @IBOutlet private weak var actionButton: UIButton!
    
    func configure(title: String, image: UIImage?, actionTitle: String? = nil) {
        messageLabel.text = title
        iconImageView.image = image
        actionButton.setTitle(actionTitle, for: .normal)
        actionButton.isHidden = actionTitle == nil
    }
    
    func configure(viewType: GalleryViewType) {
        configure(title: viewType.emptyViewMessage, image: viewType.emptyViewImage, actionTitle: viewType.emptyViewActionTitle)
    }
    
    @IBAction private func onActionButton(_ sender: UIButton) {
        delegate?.didButtonTapped()
    }
}
