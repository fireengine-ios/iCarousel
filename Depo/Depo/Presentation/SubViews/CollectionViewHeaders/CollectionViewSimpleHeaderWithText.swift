//
//  CollectionViewSimpleHeaderWithText.swift
//  Depo
//
//  Created by Oleg on 01.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

final class CollectionViewSimpleHeaderWithText: UICollectionReusableView {
    @IBOutlet private weak var backgroundVisualEffectView: UIVisualEffectView!
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = ""
            titleLabel.font = UIFont.TurkcellSaturaMedFont(size: 18)
        }
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
        if let photoVideoLayoutAttributes = layoutAttributes as? PhotoVideoCollectionViewLayoutAttributes {
            backgroundVisualEffectView.isHidden = !photoVideoLayoutAttributes.isPinned
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
