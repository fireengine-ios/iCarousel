//
//  PhotoSelectionNoFilesView.swift
//  Depo
//
//  Created by User on 9/4/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

class PhotoSelectionNoFilesView: UIView {
    
    private let imageView = UIImageView(image: UIImage(named: "ImageNoPhotos"))
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    var text:String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
            setNeedsLayout()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(imageView)
        
        label.textColor = ColorConstants.textGrayColor
        label.font = UIFont.TurkcellSaturaRegFont(size: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = TextConstants.thereAreNoPhotos
        addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labelSize = label.sizeThatFits(CGSize(width: bounds.width - 32, height: CGFloat.greatestFiniteMagnitude))
        
        let imageSize = imageView.image!.size
        
        let contentHeight = labelSize.height + 16 + imageSize.height
        let centerPoint = convert(center, from: superview!)
        
        imageView.frame.size = imageSize
        imageView.center = centerPoint
        imageView.frame.origin.y = bounds.midY - contentHeight / 2
        
        label.frame.size = labelSize
        label.center = centerPoint
        label.frame.origin.y = imageView.frame.maxY + 16
    }
}
