//
//  SaveToMyLifeboxTableViewCell.swift
//  Lifebox
//
//  Created by Burak Donat on 9.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

class SaveToMyLifeboxTableViewCell: UITableViewCell {

    @IBOutlet weak private var nameLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaFont(size: 18)
            newValue.textColor = ColorConstants.textGrayColor
        }
    }
    @IBOutlet weak private var fileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(With item: WrapData) {
        nameLabel.text = item.name
        fileImageView.image = WrapperedItemUtil.getSmallPreviewImageForWrapperedObject(fileType: item.fileType)
        //todo check if there is a default image!
        fileImageView.contentMode = .scaleAspectFit
    }
}
