//
//  OptimazingGifService.swift
//  Depo
//
//  Created by Maxim Soldatov on 1/14/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

enum OptimizationType {
    case cell
    case sticker
}

final class OptimazingGifService {
        
    func optimazeImage(data: Data, otimazeFor: OptimizationType) -> UIImage? {
        
        let percentOfFrames = otimazeFor == .sticker ? 20.0 : 80.0
        let size = otimazeFor == .sticker ? CGSize(width: 300, height: 300) : CGSize(width: 50, height: 50)
        
        guard let source: CGImageSource = CGImageSourceCreateWithData(data as CFData, nil), CGImageSourceGetCount(source) > 1 else {
            return UIImage(data: data)
        }
        
        var frames: [(image: CGImage, duration: TimeInterval)] = []
        
        for i in 0 ..< CGImageSourceGetCount(source) {
            
            let options: [CFString: Any] = [
                kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height)
            ]
            
            guard let image = CGImageSourceCreateThumbnailAtIndex(source, i, options as CFDictionary),
                let frame: [String: Any] = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
                let properties: [String: Any] = frame["{GIF}"] as? [String: Any] else {
                    continue
            }
            
            // Mimic WebKit approach to determine frame duration
            if let duration = properties["UnclampedDelayTime"] as? TimeInterval, duration > 0.0 {
                frames.append((image, duration)) // Prefer "unclamped" duration
            } else if let duration = properties["DelayTime"] as? TimeInterval, duration > 0.0 {
                frames.append((image, duration))
            } else {
                frames.append((image, 0.1)) // WebKit default
            }
        }
        
        // Convert key frames to animated image
        var images: [UIImage] = []
        var duration: TimeInterval = 0.0
        
        let newFrames = cutToNumberOfFrames(attachment: frames, cutFramesPercent: percentOfFrames)
        let kf = Double(frames.count / newFrames.count)
        
        for frame in newFrames {
            let image = UIImage(cgImage: frame.image)
            images.append(image)
            duration += (frame.duration * kf)
        }

        return UIImage.animatedImage(with: images, duration: duration)
    }
    
    
    func resizeImage(image: UIImage, targetSize: CGSize = CGSize(width: 300, height: 300)) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    
    private func cutToNumberOfFrames (attachment: [(image: CGImage, duration: TimeInterval)], cutFramesPercent: Double) -> [(image: CGImage, duration: TimeInterval)] {
        
        if attachment.count == 1  {
            return attachment
        }
        
        var images = attachment
        let imagesCount = Double(images.count)
        var index = 1
        var times = 0
        
        let numberOfFrames = imagesCount - (imagesCount / 100 * cutFramesPercent)
        
        while images.count != Int(numberOfFrames) {
            
            images.remove(at: index)
            times += 1
            index += 2
            if images.count - 1 < index {
                index = 1
            }
        }
        print("times: \(times)")
        return images
    }
    
    
    private func generateGifWithDataReturn(photos: [UIImage], completion: @escaping (Data?) -> ()) {

        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0 ]]  as CFDictionary
        let frameProperties = [kCGImagePropertyGIFDictionary as String: [(kCGImagePropertyGIFDelayTime as String): 0]] as CFDictionary
        
        let data = NSMutableData()
    
        if let destination = CGImageDestinationCreateWithData(data, kUTTypeGIF, photos.count, nil) {
            CGImageDestinationSetProperties(destination, fileProperties)
            for image in photos {
                autoreleasepool{
                    if let cgImage = image.cgImage {
                        CGImageDestinationAddImage(destination, cgImage, frameProperties)
                    }
                }
            }
            
            if CGImageDestinationFinalize(destination) {
                let data = data as Data
                completion(data)
            }
        }
    }
    
}
