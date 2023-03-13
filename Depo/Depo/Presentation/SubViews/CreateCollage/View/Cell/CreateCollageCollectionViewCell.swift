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
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.backgroundColor = .white
        view.layer.borderWidth = 1.0
        view.layer.borderColor = AppColor.collageCellBorder.cgColor
        return view
    }()
    
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
    
    func configure(collageTemplateModel: CollageTemplateElement) {
        thumbnailImage.contentMode = .scaleToFill
        thumbnailImage.sd_setImage(with: URL(string: collageTemplateModel.smallThumbnailImagePath))
    }
}

extension CreateCollageCollectionViewCell {
    private func setLayout() {
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: topAnchor, constant: 0).activate()
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).activate()
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).activate()
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).activate()
        
        containerView.addSubview(thumbnailImage)
        thumbnailImage.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImage.topAnchor.constraint(equalTo: topAnchor, constant: 10).activate()
        thumbnailImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).activate()
        thumbnailImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).activate()
        thumbnailImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).activate()
    }
}
