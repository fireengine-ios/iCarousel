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
    @IBOutlet private weak var adjustmentView: UIView! {
        willSet {
            newValue.isHidden = true
            newValue.backgroundColor = UIColor(white: 0, alpha: 0.3)
        }
    }
    @IBOutlet private weak var adjustmentImageView: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            adjustmentView.isHidden = !isSelected
            adjustmentImageView.isHidden = isOriginal
            imageContentView.transform = isSelected ? CGAffineTransform(scaleX: 1.15, y: 1.15) : .identity
            titleLabel.font = isSelected ? .TurkcellSaturaBolFont(size: 13) : .TurkcellSaturaDemFont(size: 12)
        }
    }
    
    private var isOriginal = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageContentView.backgroundColor = ColorConstants.filterBackColor
    }

    func setup(title: String, image: UIImage?, isOriginal: Bool) {
        titleLabel.text = title
        imageView.image = image
        self.isOriginal = isOriginal
    }
}
