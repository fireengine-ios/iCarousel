//
//  CollectionViewCellForStoryPhoto.swift
//  Depo_LifeTech
//
//  Created by Oleg on 17.10.17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class CollectionViewCellForStoryPhoto: CollectionViewCellForPhoto {
    
    override func setSelection(isSelectionActive: Bool, isSelected: Bool) {
        favoriteIcon.alpha = isSelectionActive ? 0 : 1
        
        selectionImageView.isHidden = !isSelectionActive
        if (isSelected) {
            selectionImageView.image = UIImage(named: "selected")
        } else {
            selectionImageView.image = nil
        }
        
        cloudStatusImage.isHidden = true
        
        let selection = isSelectionActive && isSelected
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.selectionView.alpha = selection ? 1 : 0
        }
        
    }
    
}
