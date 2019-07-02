//
//  CollectionViewSimpleHeaderWithText.swift
//  Depo
//
//  Created by Oleg on 01.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

final class CollectionViewSimpleHeaderWithText: UICollectionReusableView {
    
    @IBOutlet public weak var selectionView: UIView!
    
    @IBOutlet private weak var selectionImageView: UIImageView!
    
    @IBOutlet private weak var labelForTitle: UILabel! {
        didSet {
            labelForTitle.text = ""
            labelForTitle.font = UIFont.TurkcellSaturaMedFont(size: 18)
            labelForTitle.textColor = ColorConstants.textGrayColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = ColorConstants.bottomViewGrayColor
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
        labelForTitle.text = text
    }
    
    func setSelectedState(selected: Bool, activateSelectionState: Bool) {
        selectionImageView.isHidden = !activateSelectionState
        
        let imageName = selected ? "selected" : "notSelected"
        selectionImageView.image = UIImage(named: imageName)
    }
}
