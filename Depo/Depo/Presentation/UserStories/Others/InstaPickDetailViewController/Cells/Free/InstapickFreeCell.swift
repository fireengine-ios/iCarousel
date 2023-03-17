//
//  InstapickFreeCell.swift
//  Depo
//
//  Created by Andrei Novikau on 1/28/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class InstapickFreeCell: UICollectionViewCell {
    
    @IBOutlet private weak var shadowView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 12
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowRadius = 5
            newValue.layer.shadowOpacity = 0.3
            newValue.layer.shadowOffset = .zero
        }
    }
    
    @IBOutlet private weak var borderView: UIView! {
        willSet {
            newValue.clipsToBounds = true
            newValue.layer.cornerRadius = 12
        }
    }
    
    @IBOutlet private weak var freeLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.analyzeHistoryFreeText
            newValue.textColor = .white
            newValue.font = .appFont(.medium, size: 16)
        }
    }
}
