//
//  UIButton+Image.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 5/15/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

extension UIButton {
    /// https://stackoverflow.com/a/43785519/5893286
    func forceImageToRightSide() {
        /// or 1
        let newTransform = CGAffineTransform(scaleX: -1.0, y: 1.0) 
        transform = newTransform
        titleLabel?.transform = newTransform
        imageView?.transform = newTransform
        
        /// or 2
        //sortByButton.semanticContentAttribute = .forceRightToLeft
    }
}

extension UIButton {
    func moveImageLeftTextCenter(imagePadding: CGFloat = 30.0){
        guard let imageViewWidth = self.imageView?.frame.width else{return}
        guard let titleLabelWidth = self.titleLabel?.intrinsicContentSize.width else{return}
        self.contentHorizontalAlignment = .left
        imageEdgeInsets = UIEdgeInsets(top: 0.0, left: imagePadding - imageViewWidth / 2, bottom: 0.0, right: 0.0)
        titleEdgeInsets = UIEdgeInsets(top: 0.0, left: (bounds.width - titleLabelWidth) / 2 - imageViewWidth, bottom: 0.0, right: 4.0)

        if (2 * imagePadding) + titleLabelWidth + (2 * imageViewWidth) >= bounds.width {
            titleEdgeInsets = UIEdgeInsets(top: 0.0, left: imagePadding, bottom: 0.0, right: 4.0)
        }
    }
}
