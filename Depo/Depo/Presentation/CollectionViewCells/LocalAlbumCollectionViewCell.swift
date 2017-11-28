//
//  LocalAlbumCollectionViewCell.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 11/27/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class LocalAlbumCollectionViewCell: BaseCollectionViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameLabel.textColor = ColorConstants.textGrayColor
        nameLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
    }
    
    override func confireWithWrapperd(wrappedObj: BaseDataSourceItem) {
        guard let album = wrappedObj as? AlbumItem else{
            return
        }
        
        if let name = album.name,
            let count = album.imageCount {
            let photoCount = String(count)
            nameLabel.text = name + " (\(photoCount))"
        }
        
        
    }

}
