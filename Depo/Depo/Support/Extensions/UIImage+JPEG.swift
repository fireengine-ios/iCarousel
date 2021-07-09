//
//  UIImage+JPEG.swift
//  Depo_LifeTech
//
//  Created by Konstantin on 3/24/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import UIKit


extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case higher  = 0.99
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return self.jpegData(compressionQuality: quality.rawValue)
    }
}

extension UIImage {
    class func imageWithView(view: UIView) -> UIImage? {
           UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
           view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
           let img = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()
           return img
       }
}
