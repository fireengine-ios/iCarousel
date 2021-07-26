//
//  OptimizingGifService.swift
//  Depo
//
//  Created by Maxim Soldatov on 1/14/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

enum OptimizationType {
    case cell
    case sticker
    
    var isSticker: Bool {
        return self == .sticker
    }
}

final class OptimizingGifService {
        
    func optimizeImage(data: Data, optimizeFor: OptimizationType) -> UIImage? {
        
        let percentOfFrames = optimizeFor.isSticker ? 2 : 5
        let coeficient = optimizeFor.isSticker ? 1.2 : 1.4
        
        let size = optimizeFor.isSticker ? CGSize(width: 300, height: 300) : CGSize(width: 50, height: 50)
        
        guard let source: CGImageSource = CGImageSourceCreateWithData(data as CFData, nil), CGImageSourceGetCount(source) > 1 else {
            return UIImage(data: data)
        }
    
        let numberOfFrames = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        var gifDuration: TimeInterval = 0.0
        
        for i in 0 ..< numberOfFrames {
            
            if i != 0 && i % percentOfFrames == 0 && !(numberOfFrames < 25) {
                continue
            }
            autoreleasepool{
                let options: [CFString: Any] = [
                    kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
                    kCGImageSourceCreateThumbnailWithTransform: true,
                    kCGImageSourceShouldCacheImmediately: true,
                    kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height)
                ]
                
                guard
                    let image = CGImageSourceCreateThumbnailAtIndex(source, i, options as CFDictionary),
                    let frame: [String: Any] = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
                    let properties: [String: Any] = frame["{GIF}"] as? [String: Any]
                else {
                    return
                }
                
                let img = UIImage(cgImage: image)
                images.append(img)
                
                if let duration = properties["UnclampedDelayTime"] as? TimeInterval, duration > 0.0 {
                    gifDuration += (duration * coeficient)
                } else if let duration = properties["DelayTime"] as? TimeInterval, duration > 0.0 {
                    gifDuration += (duration * coeficient)
                } else {
                    gifDuration += (0.1 * coeficient)
                }
            }
        }
        return UIImage.animatedImage(with: images, duration: gifDuration)
    }
}
