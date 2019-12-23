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
        var rotation: CGFloat
        var images: [UIImage]
        
        init(origin: CGPoint, size: CGSize, rotation: CGFloat, images: [UIImage] ) {
            self.origin = origin
            self.size = size
            self.rotation = rotation
            self.images = images
        }
    }
    
    private let duration:TimeInterval = 2
    private var numberOfFrames = 25
    
    func getResult(attachments: [UIImageView],
                    resultName: String,
                         image: UIImage,
                    completion: @escaping (CreateOverlayStickersResult) -> ()) {
        
        guard !attachments.isEmpty else {
            completion(.failure(.emptyAttachment))
            return
        }
        
        let newImage = resizeImage(targetSize: image.size, image: image)
        
        var attach = [Attachment]()
        
        attachments.forEach({ item in
            
            let rotation = atan2(item.transform.b, item.transform.a)

            let x = item.frame.origin.x
            let y = item.frame.origin.y
            let origin = CGPoint(x: x , y: y)
        
            var images = [UIImage]()
            
            if let newItem = item.image as? YYImage {
                for index in 0 ..< newItem.animatedImageFrameCount() {
                    guard let image = newItem.animatedImageFrame(at: index) else {
                        completion(.failure(.unknown))
                        return
                    }
                    images.append(image)
                }
            } else {
                if let newItem = item.image {
                    images.append(newItem)
                }
            }
            
            let img = cutToNumberOfFrames(attachment: images, numberOfFrames: numberOfFrames)
            
            let attachment = Attachment(origin: origin, size: CGSize(width: item.bounds.width,
                                                                    height: item.bounds.width),
                                                                  rotation: rotation,
                                                                    images: img)
            
            attach.append(attachment)
        })
        
        DispatchQueue.global().async {
            
            let frameCount = attach.contains(where: { $0.images.count > 1}) ? self.numberOfFrames : 1
            
            let frames = self.renderFrames(bgImage:newImage, attacments: attach, canvasSize: newImage.size, framesCount: frameCount)

            if frameCount > 1 {
                self.generateGif(photos: frames, filename: "\(resultName)", duration: self.duration) { result in
                    switch result {
                    case let .success(url):
                        
                        guard let data = try? Data(contentsOf: url) else {
                            completion(.failure(.unknown))
                            return
                        }
                        
                        let tempUrl = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("\(resultName).mp4")
                        
                        GIF2MP4(data: data)?.convertAndExport(to: tempUrl, completion: {
                            self.saveVideo(url: tempUrl)
                            completion(.success(true))
                        })
                        
                    case let .failure(error):
                        completion(.failure(error))
                    }
                 }
            } else {

                guard let image = frames.first else {
                    completion(.failure(.unknown))
                    return
                }
                
                let url = self.saveImage(image: image, fileName: resultName)
                
                if let url = url {
                    completion(.success(true))
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
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func renderFrames(bgImage:UIImage, attacments: [Attachment], canvasSize:CGSize, framesCount: Int) -> [UIImage] {
        
        var images = [UIImage]()
        
        for _ in (0...framesCount - 1) {
            let image = renderFrame(bgImage: bgImage, canvasSize: canvasSize, newImage: nil, rect: nil, newImageSize: nil, rotation: nil)
            images.append(image)
        }
        
        for attach in attacments {
            var newImage = [UIImage]()
            for (index, image) in images.enumerated() {
                
                let indeX = attach.images.count == 1 ? attach.images.startIndex : index
                let img = renderFrame(bgImage: image, canvasSize: canvasSize, newImage: attach.images[indeX], rect: attach.origin, newImageSize: attach.size, rotation: attach.rotation)
                newImage.append(img)
            }
            images = newImage
        }
        return images
    }
    
    private func renderFrame(bgImage: UIImage, canvasSize: CGSize, newImage: UIImage?, rect: CGPoint?, newImageSize: CGSize?, rotation: CGFloat?) -> UIImage {
        
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        let image = renderer.image(actions: { context in
            
            bgImage.draw(in: CGRect(origin: CGPoint.zero, size: canvasSize))
            
            if let newImage = newImage, let rect = rect, let newSize = newImageSize, let rotation = rotation {
                
                context.cgContext.translateBy(x: rect.x, y: rect.y)
                context.cgContext.rotate(by: rotation)
                
                newImage.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
            }
        })
        return image
    }
    
    private func generateGif(photos: [UIImage], filename: String, duration: TimeInterval, completion: @escaping (OverlayStickerUrlResult) -> ()) {
        
        let photoFrameDuration = duration / Double(photos.count)
        
        guard let encoder = YYImageEncoder(type: .GIF) else {
            completion(.failure(.special))
            return
        }
        encoder.loopCount = 0

        photos.forEach({ photo in
            encoder.add(photo, duration: photoFrameDuration)
        })
        
        let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = documentsDirectoryPath.appending("/\(filename)")
        
        if encoder.encode(toFile: path) {
            let url = URL(fileURLWithPath: path)
            completion(.success(url))
        } else {
            completion(.failure(.unknown))
        }
    }
    
    func resizeImage(targetSize: CGSize, image: UIImage) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let image = renderer.image { ctx in
            image.draw(in: CGRect(origin: CGPoint.zero, size: targetSize))
        }
        return image
    }
    
    
    private func saveVideo(url: URL) {
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { saved, error in
            if saved {
                
            }
        }
    }
}
