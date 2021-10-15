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
        contentView.backgroundColor = AppColor.primaryBackground.color
    }
    
    override func configureWithWrapper(wrappedObj: BaseDataSourceItem) {
        guard let album = wrappedObj as? AlbumItem else {
            return
        }
        
        let name = album.name ?? ""
        
        if let count = album.imageCount, count > 0 {
            nameLabel.text = "\(name) (\(count))"
        } else {
            nameLabel.text = name
        }
    }

}
