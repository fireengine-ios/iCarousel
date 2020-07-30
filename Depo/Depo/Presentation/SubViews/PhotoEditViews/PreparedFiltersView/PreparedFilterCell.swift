//
//  PreparedFilterCell.swift
//  Depo
//
//  Created by Andrei Novikau on 7/30/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class PreparedFilterCell: UICollectionViewCell {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = .TurkcellSaturaDemFont(size: 12)
            newValue.textColor = .white
            newValue.textAlignment = .center
            newValue.numberOfLines = 2
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = ColorConstants.filterBackColor
    }

    func setup(title: String, image: UIImage?) {
        titleLabel.text = title
        imageView.image = image
    }
}
