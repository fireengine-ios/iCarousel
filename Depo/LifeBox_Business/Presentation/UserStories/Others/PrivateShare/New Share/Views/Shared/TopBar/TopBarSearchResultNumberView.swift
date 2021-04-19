//
//  TopBarSearchResultNumberView.swift
//  Depo
//
//  Created by Alex Developer on 12.04.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//


final class TopBarSearchResultNumberView: UICollectionReusableView, NibInit {
    
    @IBOutlet private weak var label: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = UIFont.GTAmericaStandardMediumFont(size: 16)
            newValue.textColor = ColorConstants.Text.labelTitle
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    func setNewItemsFound(itemsFoundNumber: Int) {
        label.text = String(format: TextConstants.searchItemsFoundNumber, itemsFoundNumber)
    }
    
}
