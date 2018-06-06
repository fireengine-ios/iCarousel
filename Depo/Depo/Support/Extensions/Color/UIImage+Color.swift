//
//  UIImage+Color.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 12/13/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

extension UIImage {
    convenience init?(color: UIColor) {
        let rect = CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    var grayScaleImage: UIImage? {
        /// Selim's method
        guard let cgImage = cgImage,
            let context = CGContext(data: nil,
                                    width: Int(size.width),
                                    height: Int(size.height),
                                    bitsPerComponent: 8,
                                    bytesPerRow: 0,
                                    space: CGColorSpaceCreateDeviceGray(),
                                    bitmapInfo: CGImageAlphaInfo.none.rawValue)
            else { return nil }
        
        let imageRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.draw(cgImage, in: imageRect)
        
        guard let imageRef = context.makeImage() else {
            return nil
        }
        return UIImage(cgImage: imageRef)
        
        /// CI method
        //let context = CIContext(options: nil)
        //guard let currentFilter = CIFilter(name: "CIPhotoEffectMono") else {
        //    return nil
        //}
        //currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        //guard let outputImage = currentFilter.outputImage,
        //    let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
        //    else { return nil }
        //return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }
    
    func mask(with color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext(), let cgImage = cgImage else {
            return nil
        }
        color.setFill()
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.draw(cgImage, in: rect)
        context.clip(to: rect, mask: cgImage)
        context.addRect(rect)
        context.drawPath(using: .fill)
        let coloredImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return coloredImg
    }
}
