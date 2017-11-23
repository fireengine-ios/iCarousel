//
//  CustomNavBarButton.swift
//  Depo
//
//  Created by Aleksandr on 6/22/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class CustomNavBarButton: UIButton {
    var btnName: String?
    var btnTrailingConstraintValue: CGFloat = 0
    var btnSize: CGSize = CGSize() {
        didSet {
            addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: btnSize.width))
            addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: btnSize.height))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        debugPrint("Button AWAKEd")
    }
    
    func setSize(withWidth w: CGFloat, withHeight h: CGFloat) {
        btnSize = CGSize(width: w, height: h)
    }
    
    override func setImage(_ image: UIImage?, for state: UIControlState) {
        super.setImage(image, for: state)
    }
    
}
