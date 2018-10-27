//
//  UIImage+blur.swift
//  Depo
//
//  Created by Konstantin on 10/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import GPUImage


extension UIImage {
    func blurred(with radiusInPixels: Float = 2.0) -> UIImage? {
        let filter = GPUImageGaussianBlurFilter()
        filter.blurRadiusInPixels = CGFloat(radiusInPixels)
        return filter.image(byFilteringImage: self)

    }
}
