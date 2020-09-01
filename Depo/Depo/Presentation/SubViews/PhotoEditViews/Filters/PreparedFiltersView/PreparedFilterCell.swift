//
//  PreparedFilterCell.swift
//  Depo
//
//  Created by Andrei Novikau on 7/30/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class PreparedFilterCell: UICollectionViewCell {

    @IBOutlet private weak var imageContentView: UIView!
    @IBOutlet private weak var imageView: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = .TurkcellSaturaMedFont(size: 12)
            newValue.textColor = .white
            newValue.textAlignment = .center
            newValue.numberOfLines = 2
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet private weak var adjustmentView: UIView! {
        willSet {
            newValue.isHidden = true
            newValue.backgroundColor = ColorConstants.greenyBlue.withAlphaComponent(0.6)
        }
    }
    
    @IBOutlet private weak var adjustmentImageView: UIImageView! {
        willSet {
            newValue.tintColor = .white
        }
    }
    
    override var isSelected: Bool {
        didSet {
            adjustmentView.isHidden = !isSelected || isOriginal
            adjustmentImageView.isHidden = isOriginal
            titleLabel.textColor = isSelected ? .lrTealishTwo : .white
        }
    }
    
    private var isOriginal = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageContentView.backgroundColor = ColorConstants.photoEditBackgroundColor
    }

    func setup(title: String, image: UIImage?, isOriginal: Bool) {
        titleLabel.text = title
        imageView.image = image
        self.isOriginal = isOriginal
    }
}
