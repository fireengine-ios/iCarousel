//
//  CollectionViewHeaderWithText.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 10.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class CollectionViewHeaderWithText: UICollectionReusableView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configurateView()
    }
    
    func configurateView() {
        titleLabel.text = TextConstants.createStoryPhotosHeaderTitle
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        titleLabel.textColor = ColorConstants.lightText
    }
}
