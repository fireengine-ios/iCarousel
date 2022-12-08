//
//  PlaceTableViewCell.swift
//  Lifebox
//
//  Created by Ozan Salman on 17.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import Combine
import UIKit

class DiscoverTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let myCustomSelectionColorView = UIView()
        selectedBackgroundView = myCustomSelectionColorView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var bgView: UIView! {
        willSet {
            newValue.addRoundedShadows(cornerRadius: 15, shadowColor: AppColor.drawerShadow.cgColor, opacity: 0.3, radius: 4)
            newValue.backgroundColor = AppColor.secondaryBackground.color
        }
    }
    
    @IBOutlet weak var thumbnailImage: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFill
            newValue.layer.cornerRadius = 15
        }
    }
    
    
    func configure(with card: HomeCardResponse) {
        guard let details = card.details?["thumbnail"],
              let urlStr = details as? String,
              urlStr != "" else { return }
        
        let url = URL(string: urlStr)
        thumbnailImage.sd_setImage(with: url)
    }
}
