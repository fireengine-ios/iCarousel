//
//  CreateCollageCollectionViewCell.swift
//  Lifebox
//
//  Created by Ozan Salman on 3.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage

class CreateCollageCollectionViewCell: UICollectionViewCell {
    
    private lazy var thumbnailImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
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
    
    func configure(collageTemplateModel: CollageTemplateElement) {
        //thumbnailImage.image = UIImage(named: "AppIcon")
        thumbnailImage.sd_setImage(with: URL(string: collageTemplateModel.smallThumbnailImagePath))
    }
}

extension CreateCollageCollectionViewCell {
    private func setLayout() {
        addSubview(thumbnailImage)
        thumbnailImage.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImage.topAnchor.constraint(equalTo: topAnchor, constant: 6).activate()
        thumbnailImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).activate()
        thumbnailImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6).activate()
        thumbnailImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).activate()
    }
}
