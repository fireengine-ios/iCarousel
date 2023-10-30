//
//  PhotoPrintSeeAllCollectionViewCell.swift
//  Depo
//
//  Created by Ozan Salman on 26.09.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

class PhotoPrintSeeAllCollectionViewCell: UICollectionViewCell {
    
    private lazy var thumbnailImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.layer.cornerRadius = 5
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(urlString: String) {
        let url = URL(string: urlString)
        thumbnailImage.contentMode = .scaleToFill
        thumbnailImage.sd_setImage(with: url)
    }
}

extension PhotoPrintSeeAllCollectionViewCell {
    private func setLayout() {
        addSubview(thumbnailImage)
        thumbnailImage.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImage.topAnchor.constraint(equalTo: topAnchor, constant: 0).activate()
        thumbnailImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).activate()
        thumbnailImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).activate()
        thumbnailImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).activate()
    }
}
