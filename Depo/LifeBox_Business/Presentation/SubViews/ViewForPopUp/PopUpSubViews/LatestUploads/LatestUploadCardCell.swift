//
//  LatestUploadCardCell.swift
//  Depo
//
//  Created by Oleg on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class LatestUploadCardCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: LoadingImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = ColorConstants.fileGreedCellColor
    }
    
    func setImage(image: Item) {
        iconImageView.loadImage(with: image)
    }
}
