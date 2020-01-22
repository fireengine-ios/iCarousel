//
//  GifToMP4Formatter.swift
//  Depo
//
//  Created by Maxim Soldatov on 12/19/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation
import AVFoundation

final class GIF2MP4 {
    
    private var outputURL: URL?
    private(set) var videoWriter: AVAssetWriter?
    private(set) var videoWriterInput: AVAssetWriterInput?
    private(set) var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    
    private var images = [CGImage]()
    
    var videoSize : CGSize {
        //The size of the video must be a multiple of 16
        guard let image = images.first else {
            return .zero
        }
        
        let width = Double(image.width)
        let height = Double(image.height)
        
        return CGSize(width: floor(width / 16) * 16, height: floor(height / 16) * 16)
    }
    
    init?(images: [UIImage]) {
        images.forEach({
            self.images.append($0.cgImage)
        })
        self.images.append(contentsOf: self.images)
    }
    
    private func prepare() {
        
        let fileManager = FileManager.default
        
        guard let outputURL = outputURL else {
            assertionFailure()
            return
        }
        
        let avOutputSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecH264,
            AVVideoWidthKey: NSNumber(value: Float(videoSize.width)),
            AVVideoHeightKey: NSNumber(value: Float(videoSize.height))
        ]
        
        let sourcePixelBufferAttributesDictionary = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32ARGB),
            kCVPixelBufferWidthKey as String: NSNumber(value: Float(videoSize.width)),
            kCVPixelBufferHeightKey as String: NSNumber(value: Float(videoSize.height))
        ]
        
        videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: avOutputSettings)
        
        do {
            if fileManager.fileExists(atPath: outputURL.path) {
                 try fileManager.removeItem(atPath: outputURL.path)
            }
            
            videoWriter = try AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mp4)
            
        } catch let error {
            print(error.localizedDescription)
            assertionFailure()
        }
        
        guard let videoWriter = videoWriter, let videoWriterInput = videoWriterInput else {
            assertionFailure()
            return
        }
        
        videoWriter.add(videoWriterInput)
        
        pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
        videoWriter.startWriting()
        videoWriter.startSession(atSourceTime: kCMTimeZero)
    }
    
    func convertAndExport(fileName: String , completion: @escaping (URL?) -> Void ) {
        
        outputURL = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("\(fileName).mp4")
        prepare()
        
        guard let videoWriterInput = videoWriterInput, let videoWriter = videoWriter else {
            completion(nil)
            return
        }

        var index = 0
        var delay = 0.0
        let queue = DispatchQueue(label: "mediaInputQueue")
        
        videoWriterInput.requestMediaDataWhenReady(on: queue) {
    
            while index < self.images.count {
                
                if videoWriterInput.isReadyForMoreMediaData == true {
                    autoreleasepool{
                        delay += 0.1
                        let presentationTime = CMTime(seconds: delay, preferredTimescale: 600)
                        let result = self.addImage(image: UIImage(cgImage: self.images[index]), withPresentationTime: presentationTime)
                        if result == false {
                            assertionFailure()
                        } else {
                            index += 1
                        }
                    }
                }
            }
            
            videoWriterInput.markAsFinished()
            videoWriter.finishWriting() {
                DispatchQueue.main.async {
                    guard let url = self.outputURL else {
                        completion(nil)
                        return
                    }
                    completion(url)
                }
            }
        }
    }
    
    func addImage(image: UIImage, withPresentationTime presentationTime: CMTime) -> Bool {
        
        guard let pixelBufferAdaptor = pixelBufferAdaptor, let pixelBufferPool = pixelBufferAdaptor.pixelBufferPool else {
            assertionFailure("pixelBufferPool is nil ")
            return false
        }
        
        guard let pixelBuffer = pixelBufferFromImage(image: image, pixelBufferPool: pixelBufferPool, size: videoSize) else {
            assertionFailure()
            return false
        }
        return pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
    }

    func pixelBufferFromImage(image: UIImage, pixelBufferPool: CVPixelBufferPool, size: CGSize) -> CVPixelBuffer? {
        var pixelBufferOut: CVPixelBuffer?
        let status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, &pixelBufferOut)
        if status != kCVReturnSuccess {
            assertionFailure("CVPixelBufferPoolCreatePixelBuffer() failed")
        }
        
        guard let pixelBuffer = pixelBufferOut else {
            assertionFailure()
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))

        let data = CVPixelBufferGetBaseAddress(pixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: data,
                                     width: Int(size.width),
                                    height: Int(size.height),
                          bitsPerComponent: 8,
                               bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                     space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue),
                                      let CGimage = image.cgImage
        else {
                assertionFailure()
                return nil
        }

        context.clear(CGRect(x: 0, y: 0, width: size.width, height: size.height))

        let horizontalRatio = size.width / image.size.width
        let verticalRatio = size.height / image.size.height
        let aspectRatio = max(horizontalRatio, verticalRatio) // ScaleAspectFill
        let newSize = CGSize(width: image.size.width * aspectRatio, height: image.size.height * aspectRatio)

        let x = newSize.width < size.width ? (size.width - newSize.width) / 2 : -(newSize.width-size.width)/2
        let y = newSize.height < size.height ? (size.height - newSize.height) / 2 : -(newSize.height-size.height)/2

        context.draw(CGimage, in: CGRect(x:x, y:y, width:newSize.width, height:newSize.height))
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))

        return pixelBuffer
    }
}
