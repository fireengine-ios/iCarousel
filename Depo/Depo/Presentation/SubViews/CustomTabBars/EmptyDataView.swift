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

private extension ElementTypes {
    
    var emptyViewMessage: String {
        switch self {
        case .galleryAll:
            //return "Henüz hiç fotoğraf eklenmemiş"
            return localized(.emptyGalleryNoPhoto)
        case .gallerySync:
            //return "Tüm ögelerin Unsync olmuş durumda"
            return localized(.emptyGalleryNoSync)
        case .galleryUnsync:
            //return "Tüm dosyaların yedekli"
            return localized(.emptyGalleryNoUnsync)
        case .galleryVideos:
            //return "Henüz hiç video eklenmemiş"
            return localized(.emptyGalleryNoVideo)
        case .galleryPhotos:
            //return "Henüz hiç fotoğraf eklenmemiş"
            return localized(.emptyGalleryNoPhoto)
        default:
            return ""
        }
    }
    
    var emptyViewActionTitle: String? {
        switch self {
        case .galleryAll:
            return TextConstants.photosVideosViewNoPhotoButtonText
        default: return nil
        }
    }
    
    var emptyViewImage: UIImage? {
        switch self {
        case .galleryAll:
            return Image.popupNoMemories.image
        case .gallerySync:
            return Image.popupUnsync.image
        case .galleryUnsync:
            return Image.popupSuccessful.image
        case .galleryVideos:
            return Image.popupNoVideo.image
        case .galleryPhotos:
            return Image.popupNoMemories.image
        default:
            return nil
        }
    }
}

final class EmptyDataView: UIView, NibInit {
    weak var delegate: EmptyDataViewDelegate?
    
    @IBOutlet private weak var messageLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.medium, size: 16)
        }
    }
    
    @IBOutlet private weak var iconImageView: UIImageView!
    
    @IBOutlet private weak var actionButton: DarkBlueButton!
    
    func configure(viewType: ElementTypes) {
        messageLabel.text = viewType.emptyViewMessage
        iconImageView.image = viewType.emptyViewImage
        actionButton.setTitle(viewType.emptyViewActionTitle ?? "", for: .normal)
        actionButton.isHidden = viewType.emptyViewActionTitle == nil
    }
    
    @IBAction private func onActionButton(_ sender: UIButton) {
        delegate?.didButtonTapped()
    }
}
