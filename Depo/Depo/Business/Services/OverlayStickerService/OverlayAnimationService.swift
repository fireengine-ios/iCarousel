//
//  OverlayAnimationService.swift
//  Depo
//
//  Created by Maxim Soldatov on 12/19/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import ImageIO
import YYImage
import Photos

final class OverlayAnimationService {
    
    final private class Attachment {
        
        var origin: CGPoint
        var size: CGSize
        var images: [UIImage]
        var transform: CGAffineTransform
        
        init(origin: CGPoint, size: CGSize, images: [UIImage], transform: CGAffineTransform) {
            self.origin = origin
            self.size = size
            self.images = images
            self.transform = transform
        }
    }
    
    private let duration:TimeInterval = 2.5
    private var numberOfFrames = 25
    
    func combine(attachments: [UIImageView],
                  resultName: String,
               originalImage: UIImage,
                  completion: @escaping (CreateOverlayStickersResult) -> ()) {
        
        guard !attachments.isEmpty else {
            completion(.failure(.emptyAttachment))
            return
        }
        
        var attach = [Attachment]()
        
        attachments.forEach({ item in
            
            let transform = item.transform
    
            let x = item.center.x
            let y = item.center.y
            let origin = CGPoint(x: x , y: y)
            
            var images = [UIImage]()
        
            if let newItem =  item.image as? YYImage {
                
                guard
                    let data = newItem.animatedImageData,
                    let gifImage = UIImage.gifImageWithData(data: data as NSData),
                    let imgs = gifImage.images
                else {
                    assertionFailure()
                    return
                }

                images.append(contentsOf: imgs)
                
            } else {
                if let newItem = item.image {
                    images.append(newItem)
                }
            }
            
            let frames = cutToNumberOfFrames(attachment: images, numberOfFrames: numberOfFrames)
            
            let attachment = Attachment(origin: origin,
                                          size: CGSize(width: item.bounds.width,
                                        height: item.bounds.width),
                                        images: frames,
                                     transform: transform)
            
            attach.append(attachment)
        })
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let frameCount = attach.contains(where: { $0.images.count > 1}) ? self.numberOfFrames : 1
            
            let frames = self.renderFrames(bgImage:originalImage, attacments: attach, canvasSize: originalImage.size, framesCount: frameCount)

            if frameCount > 1 {
                self.generateGif(photos: frames, filename: "\(resultName)", duration: self.duration) { result in
                    
                    guard let data = result else {
                        completion(.failure(.unknown))
                        return
                    }
                    
                    let tempUrl = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("\(resultName).mp4")
                    
                    GIF2MP4(data: data)?.convertAndExport(to: tempUrl, completion: {
                        completion(.success(CreateOverlayStickersSuccessResult(url: tempUrl, type: .video)))
                    })
                 }
            } else {

                guard let image = frames.first else {
                    completion(.failure(.unknown))
                    return
                }
                
                let url = self.saveImage(image: image, fileName: resultName)
                
                if let url = url {
                    completion(.success(CreateOverlayStickersSuccessResult(url: url, type: .image)))
                } else {
                    completion(.failure(.unknown))
                }
            }
        }
    }
    
    private func cutToNumberOfFrames (attachment: [UIImage], numberOfFrames: Int) -> [UIImage] {
        
        if attachment.count == 1  {
            return attachment
        } else if attachment.count <= numberOfFrames {
            self.numberOfFrames = attachment.count
        }
        
        var images = attachment
        var index = 1
        
        while images.count != numberOfFrames {
        
            images.remove(at: index)
            index += 2
            if images.count - 1 < index {
                index = 1
            }
        }
        return images
    }
    
    private func saveImage(image: UIImage, fileName: String) -> URL? {
    
        guard let data = image.jpeg(.highest) ?? UIImagePNGRepresentation(image)  else {
            return nil
        }
        
        let format = ImageFormat.get(from: data) == .jpg ? ".jpg" : ".png"
        
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return nil
        }
        
        do {
            guard let path = directory.appendingPathComponent(fileName + format) else {
                assertionFailure()
                return nil
            }
            
            try data.write(to: path)
            return path
        } catch {
            return nil
        }
    }
    
    private func renderFrames(bgImage:UIImage, attacments: [Attachment], canvasSize:CGSize, framesCount: Int) -> [UIImage] {
        
        var images = Array.init(repeating: bgImage, count: framesCount)
        
        for attach in attacments {
            autoreleasepool {
                
                var newImage = [UIImage]()
                
                for (index, image) in images.enumerated() {
                    
                    autoreleasepool {
                        let indeX = attach.images.count == 1 ? attach.images.startIndex : index
                        let img = renderFrame(bgImage: image, canvasSize: canvasSize, newImage: attach.images[indeX], rect: attach.origin, newImageSize: attach.size, transform: attach.transform)
                        newImage.append(img)
                    }
                }
                images = newImage
            }
        }
        return images
    }
    
    private func renderFrame(bgImage: UIImage, canvasSize: CGSize, newImage: UIImage?, rect: CGPoint?, newImageSize: CGSize?, transform: CGAffineTransform) -> UIImage {
        
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        
        let image = renderer.image(actions: { context in
            bgImage.draw(in: CGRect(origin: CGPoint.zero, size: canvasSize))
            
            if let newImage = newImage, let rect = rect, let newSize = newImageSize {
                context.cgContext.translateBy(x: rect.x, y: rect.y)
                context.cgContext.concatenate(transform)
                context.cgContext.translateBy(x: -newSize.width * 0.5,
                                              y: -newSize.height * 0.5)
                newImage.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
            }
        })
        return image
    }
    
    private func generateGif(photos: [UIImage], filename: String, duration: TimeInterval, completion: @escaping (Data?) -> ()) {
        
        let photoFrameDuration = duration / Double(photos.count)
        
        guard let encoder = YYImageEncoder(type: .GIF) else {
            completion(nil)
            return
        }
        
        encoder.loopCount = 0
        
        photos.forEach({ photo in
            encoder.add(photo, duration: photoFrameDuration)
        })
        
        photos.forEach({ photo in
            encoder.add(photo, duration: photoFrameDuration)
        })
        
        if let data = encoder.encode() {
            completion(data)
        } else {
            completion(nil)
        }
    }
}
