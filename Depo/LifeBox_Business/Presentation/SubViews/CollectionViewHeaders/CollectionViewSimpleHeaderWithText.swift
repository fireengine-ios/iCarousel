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
            labelForTitle.textColor = ColorConstants.textGrayColor.color
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = ColorConstants.bottomViewGrayColor.color
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
