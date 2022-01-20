//
//  PublicSharedItemsTableViewCell.swift
//  Lifebox
//
//  Created by Burak Donat on 9.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage

class PublicSharedItemsTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var nameLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaFont(size: 19)
            newValue.textColor = ColorConstants.textGrayColor
        }
    }
    @IBOutlet weak private var fileImageView: UIImageView!
    
    func configure(With item: WrapData) {
        nameLabel.text = item.name
        fileImageView.contentMode = .center
        
        switch item.patchToPreview {
        case .remoteUrl(let url):
            if let url = url {
                fileImageView.sd_setImage(with: url, completed: nil)
                fileImageView.contentMode = .scaleAspectFill
            } else {
                fileImageView.image = WrapperedItemUtil.getSmallPreviewImageForWrapperedObject(fileType: item.fileType)
            }
            return
        default:
            break
        }
        fileImageView.image = WrapperedItemUtil.getSmallPreviewImageForWrapperedObject(fileType: item.fileType)
        fileImageView.clipsToBounds = true
    }
}
