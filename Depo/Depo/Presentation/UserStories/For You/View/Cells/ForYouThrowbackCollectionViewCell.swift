//
//  ForYouThrowbackCollectionViewCell.swift
//  Depo
//
//  Created by Burak Donat on 6.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

class ForYouThrowbackCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var thumbnailImage: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFill
            newValue.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 2
            newValue.font = .appFont(.medium, size: 14)
            newValue.textColor = .white
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addGradientLayer()
    }
    
    func configure(with throwbackData: ThrowbackData) {
        titleLabel.text = throwbackData.name
        
        if let url = throwbackData.coverPhoto?.metadata?.thumbnailMedium, let wrappedUrl = URL(string: url) {
            thumbnailImage.sd_setImage(with: wrappedUrl, completed: nil)
        }
    }
    
    private func addGradientLayer() {
        thumbnailImage.addGradient(firstColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor,
                                   secondColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor)
    }
}
