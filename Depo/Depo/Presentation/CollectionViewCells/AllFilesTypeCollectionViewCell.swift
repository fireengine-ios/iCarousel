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
    case favorites
    case trashBin
    case sharedWithMe
    case music
    case sharedByMe
    case allFiles
    case documentsAndMusic
    
    var image: UIImage? {
        switch self {
        case .documents:
            return Image.iconTabFiles.image
        case .favorites:
            return Image.iconTabStar.image
        case .trashBin:
            return Image.iconTabDelete.image
        case .sharedByMe, .sharedWithMe:
            return Image.iconTabShare.image
        case .music:
            return Image.iconTabMusic.image
        case .allFiles, .documentsAndMusic:
            return nil
        }
    }

    var accessibilityLabel: String? {
        switch self {
        case .documents:
            return TextConstants.containerDocument
        case .favorites:
            return TextConstants.containerFavourite
        case .trashBin:
            return localized(.trashBin)
        case .sharedByMe, .sharedWithMe:
            return TextConstants.containerShared
        case .music:
            return TextConstants.containerMusic
        case .allFiles, .documentsAndMusic:
            return nil
        }
    }
    
    var tintColor: UIColor? {
        switch self {
        case .documents:
            return AppColor.filesDocumentTab.color
        case .favorites:
            return AppColor.filesFavoriteTab.color
        case .trashBin:
            return AppColor.filesDocumentTab.color
        case .sharedByMe, .sharedWithMe:
            return AppColor.filesSharedTab.color
        case .music:
            return AppColor.filesMusicTab.color
        case .allFiles, .documentsAndMusic:
            return nil
        }
    }
    
    static func getSegments() -> [AllFilesType] {
        return [.documents, .favorites, .trashBin, .sharedWithMe, .music]
    }
    
    static func getSharedItemsSegments() -> [AllFilesType] {
        return [.sharedWithMe, .sharedByMe]
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
                                       opacity: 0.4, radius: 4.0, offset: CGSize(width: .zero, height: 4.0))
            newValue.backgroundColor = AppColor.filesTypesBackground.color
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        typeView.addRoundedShadows(cornerRadius: 12,
                                   shadowColor: AppColor.filesBigCellShadow.cgColor,
                                   opacity: 0.4, radius: 4.0, offset: CGSize(width: .zero, height: 4.0))
        typeView.backgroundColor = AppColor.filesTypesBackground.color
    }
    
    func configure(with type: AllFilesType) {
        typeLabel.accessibilityLabel = type.accessibilityLabel
        typeLabel.text = type.accessibilityLabel
        typeIcon.image = type.image
    }
    
    func setSelection(with type: AllFilesType, isSelected: Bool) {
        if isSelected {
            typeIcon.image = Image.iconSelectCheck.image.withRenderingMode(.alwaysTemplate)
            typeIcon.tintColor = type.tintColor
            typeView.layer.borderColor = type.tintColor?.cgColor
            typeView.layer.borderWidth = 1
            typeView.layer.shadowRadius = 0
        } else {
            configure(with: type)
            typeView.layer.borderWidth = 0
            typeView.layer.shadowRadius = 4.0
        }
    }
}
