//
//  CollectionViewStoryReorderView.swift
//  Depo_LifeTech
//
//  Created by Oleg on 15.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class CollectionViewStoryReorderView: UICollectionReusableView {
    
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLabel.text = TextConstants.createStoryPhotosOrderTitle
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        titleLabel.textColor = ColorConstants.lightGrayColor
    }
    
}
