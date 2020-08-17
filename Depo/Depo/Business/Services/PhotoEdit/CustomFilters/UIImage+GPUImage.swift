//
//  UIImage+GPUImage.swift
//  InstaFilter
//
//  Created by Konstantin Studilin on 22.06.2020.
//  Copyright © 2020 Konstantin. All rights reserved.
//

import Foundation
import UIKit
import GPUImage

extension UIImage {
    public func adjusting(vignetteAlpha: Float) -> UIImage {
        let filter = Vignette()
        filter.color = Color(red: 0, green: 0, blue: 0, alpha: vignetteAlpha)
        
        let filtered = self.filterWithPipeline { input, output in
            input --> filter --> output
        }
        
        return filtered
    }
    
    func resize(newWidth: CGFloat) -> UIImage? {

      let scale = newWidth / size.width
      let newHeight = size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
      let newImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()

      return newImage
    }
}
