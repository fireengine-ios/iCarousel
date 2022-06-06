//
//  AllFilesTypeCollectionViewCell.swift
//  Depo
//
//  Created by Burak Donat on 2.06.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

enum AllFilesType: CaseIterable {
    case documents
    case music
    case favorites
    case shared
    
    var image: UIImage? {
        switch self {
        case .documents:
            return Image.iconTabFiles.image
        case .music:
            return Image.iconTabMusic.image
        case .favorites:
            return Image.iconTabStar.image
        case .shared:
            return Image.iconTabShare.image
        }
    }

    var accessibilityLabel: String? {
        switch self {
        case .documents:
            return TextConstants.containerDocument
        case .music:
            return TextConstants.containerMusic
        case .favorites:
            return TextConstants.containerFavourite
        case .shared:
            return TextConstants.containerShared
        }
    }
    
    var tintColor: UIColor? {
        switch self {
        case .documents:
            return AppColor.filesDocumentTab.color
        case .music:
            return AppColor.filesMusicTab.color
        case .favorites:
            return AppColor.filesFavoriteTab.color
        case .shared:
            return AppColor.filesSharedTab.color
        }
    }
}

class AllFilesTypeCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var typeIcon: UIImageView!
    @IBOutlet private weak var typeLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.filesLabel.color
            newValue.font = UIFont.appFont(.medium, size: 14)
        }
    }
    
    @IBOutlet private weak var typeView: UIView! {
        willSet {
            newValue.addRoundedShadows(cornerRadius: 12,
                                       shadowColor: AppColor.filesBigCellShadow.cgColor,
                                       opacity: 0.8, radius: 6.0)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with type: AllFilesType) {
        typeLabel.accessibilityLabel = type.accessibilityLabel
        typeLabel.text = type.accessibilityLabel
        typeIcon.image = type.image
    }
    
    func setSelection(with type: AllFilesType, isSelected: Bool) {
        if isSelected {
            typeIcon.image = Image.iconCheckmarkSelected.image
            typeIcon.tintColor = type.tintColor
            typeView.layer.borderColor = type.tintColor?.cgColor
            typeView.layer.borderWidth = 1
        } else {
            configure(with: type)
            typeView.layer.borderWidth = 0
        }
    }
}
