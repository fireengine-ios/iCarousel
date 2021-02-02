//
//  MultifileCollectionViewCell.swift
//  Depo
//
//  Created by Konstantin Studilin on 02.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

class MultifileCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var thumbnail: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFit
        }
    }
    
    @IBOutlet private weak var name: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 14.0)
//            newValue.textColor = 
        }
    }
    @IBOutlet private weak var lastModifiedDate: UILabel!
    @IBOutlet private weak var iconsStack: UIStackView!
    @IBOutlet private weak var menuButton: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
