//
//  CollectionViewSimpleHeaderWithText.swift
//  Depo
//
//  Created by Oleg on 01.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

final class CollectionViewSimpleHeaderWithText: UICollectionReusableView {

    private enum Constants {
        static let menuButtonAccessibilityId = "CollectionViewSimpleHeaderMenuButton"
        static let titleLabelAccessibilityId = "CollectionViewSimpleHeaderTitleLabel"
    }

    @IBOutlet private weak var menuButton: UIButton! {
        willSet {
            // TODO: Facelift, icons tint?
            let image = Image.iconThreeDotsHorizontal.image(withTintColor: .label, in: newValue)
            newValue.setImage(image, for: .normal)
            newValue.isHidden = true
            newValue.accessibilityLabel = TextConstants.accessibilityMore
            newValue.accessibilityIdentifier = Constants.menuButtonAccessibilityId
        }
    }

    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.textColor = AppColor.label.color
            newValue.font = AppFontPresets.title2
            newValue.adjustsFontForContentSizeCategory = true
            newValue.accessibilityIdentifier = Constants.titleLabelAccessibilityId
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = AppColor.background.color
    }

    func setup(with object: MediaItem) {
        let title: String
        if object.monthValue != nil, let date = object.sortingDate as Date? {
            title = date.getDateInTextForCollectionViewHeader()
        } else {
            title = TextConstants.photosVideosViewMissingDatesHeaderText
        }
        setText(text: title)
    }

    func setText(text: String?) {
        titleLabel.text = text
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        if let photoVideoLayoutAttributes = layoutAttributes as? GalleryCollectionViewLayoutAttributes {
            let isFirstHeader = photoVideoLayoutAttributes.indexPath.section == 0
            let showsMenuButton = photoVideoLayoutAttributes.isPinned || isFirstHeader
            menuButton.isHidden = !showsMenuButton
        }
    }

    // TODO: Facelift. this seems to be unused, check when doing the files refactor.
    let selectionView = UIView()
    func setSelectedState(selected: Bool, activateSelectionState: Bool) {
//        selectionImageView.isHidden = !activateSelectionState
//
//        let imageName = selected ? "selected" : "notSelected"
//        selectionImageView.image = UIImage(named: imageName)
    }
}
