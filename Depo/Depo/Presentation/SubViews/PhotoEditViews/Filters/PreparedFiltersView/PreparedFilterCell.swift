//
//  PreparedFilterCell.swift
//  Depo
//
//  Created by Andrei Novikau on 7/30/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class PreparedFilterCell: UICollectionViewCell {

    @IBOutlet private weak var imageContentView: UIView! {
        willSet {
            newValue.layer.borderColor = AppColor.tabBarSelect.cgColor
            newValue.layer.cornerRadius = 2
            newValue.layer.masksToBounds = true
        }
    }
    
    @IBOutlet private weak var imageView: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.bold, size: 12)
            newValue.textColor = AppColor.tabBarSelect.color
            newValue.textAlignment = .center
            newValue.numberOfLines = 2
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet private weak var adjustmentView: UIView! {
        willSet {
            newValue.isHidden = true
            newValue.backgroundColor = .black.withAlphaComponent(0.7)
        }
    }
    
    @IBOutlet private weak var adjustmentImageView: UIImageView! {
        willSet {
            newValue.image = Image.iconSettingsFilter.image.withRenderingMode(.alwaysTemplate)
            newValue.tintColor = AppColor.tabBarSelect.color
        }
    }
    
    override var isSelected: Bool {
        didSet {
            adjustmentView.isHidden = !isSelected || isOriginal
            adjustmentImageView.isHidden = isOriginal
            titleLabel.textColor = isSelected ? AppColor.tabBarSelect.color : .white
            
            imageContentView.layer.borderWidth = !isSelected || isOriginal ? 0 : 1.5
        }
    }
    
    private var isOriginal = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
        imageView.image = nil
        isOriginal = true
    }

    func setup(title: String, image: UIImage?, isOriginal: Bool) {
        titleLabel.text = title
        imageView.image = image
        self.isOriginal = isOriginal
    }
}
