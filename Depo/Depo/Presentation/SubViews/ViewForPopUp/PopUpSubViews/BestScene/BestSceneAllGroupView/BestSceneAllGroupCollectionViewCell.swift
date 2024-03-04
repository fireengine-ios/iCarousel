//
//  BestSceneAllGroupCollectionViewCell.swift
//  Depo
//
//  Created by Rustam Manafov on 04.03.24.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import UIKit

class BestSceneAllGroupCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    let topShadowView = UIImageView()
    let bottomShadowView = UIImageView()
    
     lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont(name: "TurkcellSaturaMed", size: 12)
        label.textColor = UIColor(red: 0.01, green: 0.11, blue: 0.16, alpha: 1.00)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        topShadowView.translatesAutoresizingMaskIntoConstraints = false
        bottomShadowView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imageView)
        contentView.insertSubview(bottomShadowView, belowSubview: imageView)
        contentView.insertSubview(topShadowView, belowSubview: bottomShadowView)
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            bottomShadowView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 8),
            bottomShadowView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8),
            bottomShadowView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10),
            bottomShadowView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            topShadowView.leadingAnchor.constraint(equalTo: bottomShadowView.leadingAnchor, constant: 10),
            topShadowView.trailingAnchor.constraint(equalTo: bottomShadowView.trailingAnchor, constant: -10),
            topShadowView.bottomAnchor.constraint(equalTo: bottomShadowView.bottomAnchor, constant: -10),
            topShadowView.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            dateLabel.heightAnchor.constraint(equalToConstant: 20),
            dateLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 2)
        ])
        
        imageView.contentMode = .scaleAspectFill
        
        imageView.clipsToBounds = true
        bottomShadowView.clipsToBounds = true
        topShadowView.clipsToBounds = true
        
        imageView.layer.cornerRadius = 8
        bottomShadowView.layer.cornerRadius = 4
        topShadowView.layer.cornerRadius = 4
        
        bottomShadowView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        topShadowView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        bottomShadowView.alpha = 0.8
        topShadowView.alpha = 0.3
    }
}
