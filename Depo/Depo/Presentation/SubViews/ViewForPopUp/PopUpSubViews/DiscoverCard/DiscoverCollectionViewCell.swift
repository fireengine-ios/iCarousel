//
//  DiscoverCollectionViewCell.swift
//  Lifebox
//
//  Created by Rustam Manafov on 13.02.24.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import UIKit

class DiscoverCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    let topShadowView = UIImageView()
    let bottomShadowView = UIImageView()
    
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
        
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            bottomShadowView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 8),
            bottomShadowView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -9),
            bottomShadowView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10),
            bottomShadowView.heightAnchor.constraint(equalToConstant: 125)
        ])
        
        NSLayoutConstraint.activate([
            topShadowView.leadingAnchor.constraint(equalTo: bottomShadowView.leadingAnchor, constant: 10),
            topShadowView.trailingAnchor.constraint(equalTo: bottomShadowView.trailingAnchor, constant: -10),
            topShadowView.bottomAnchor.constraint(equalTo: bottomShadowView.bottomAnchor, constant: -6),
            topShadowView.heightAnchor.constraint(equalToConstant: 125)
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
