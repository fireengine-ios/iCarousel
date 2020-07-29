//
//  FilterCategoryCell.swift
//  Depo
//
//  Created by Andrei Novikau on 7/29/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class FilterCategoryCell: UICollectionViewCell {

    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = .white
            newValue.textAlignment = .center
            newValue.font = .TurkcellSaturaDemFont(size: 14)
        }
    }
    
    @IBOutlet private weak var imageView: UIImageView! {
        willSet {
            newValue.contentMode = .center
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = filterBackColor
    }
    
    func setup(with title: String, image: UIImage?) {
        titleLabel.text = title
        imageView.image = image
    }

}
