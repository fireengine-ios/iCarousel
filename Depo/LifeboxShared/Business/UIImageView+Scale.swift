//
//  UIImageView+Scale.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 3/6/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

extension UIImageView {
    func setScreenScaledImage(_ newImage: UIImage?) {
        image = newImage?.resizedImage(to: bounds.size.screenScaled)
    }
}
