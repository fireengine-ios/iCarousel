//
//  AdjustmentCategoryCell.swift
//  Depo
//
//  Created by Andrei Novikau on 7/29/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class AdjustmentCategoryCell: UICollectionViewCell {

    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = .white
            newValue.textAlignment = .center
            newValue.font = Device.isIpad ? .appFont(.regular, size: 14) : .appFont(.regular, size: 12)
        }
    }
    
    @IBOutlet private weak var imageView: UIImageView! {
        willSet {
            newValue.tintColor = .white
        }
    }
    
    @IBOutlet private weak var imageSide: NSLayoutConstraint!
    @IBOutlet private weak var topOffset: NSLayoutConstraint!
    @IBOutlet private weak var bottomOffset: NSLayoutConstraint!
    
    override var isHighlighted: Bool {
        didSet {
            updateStyle()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            updateStyle()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = ColorConstants.photoEditBackgroundColor
        imageSide.constant = Device.isIpad ? 33 : 29
        topOffset.constant = Device.isIpad ? 28 : 14
        bottomOffset.constant = Device.isIpad ? 27 : 12
    }
    
    func setup(with title: String, image: UIImage?) {
        titleLabel.text = title
        imageView.image = image
        imageView.highlightedImage = image?.withRenderingMode(.alwaysTemplate).mask(with: AppColor.tabBarSelect.color)
    }
    
    private func updateStyle() {
        imageView.isHighlighted = isHighlighted
        titleLabel.textColor = isHighlighted ? AppColor.tabBarSelect.color : .white
    }
}
