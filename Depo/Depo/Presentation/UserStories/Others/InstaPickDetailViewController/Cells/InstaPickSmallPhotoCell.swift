//
//  InstaPickSmallPhotoCell.swift
//  Depo
//
//  Created by yilmaz edis on 16.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

final class InstaPickSmallPhotoCell: UICollectionViewCell {
    @IBOutlet weak var smallPhoto: InstaPickSmallPhotoView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with analyze: InstapickAnalyze) {
        smallPhoto.configureImageView(with: analyze)
    }
}
