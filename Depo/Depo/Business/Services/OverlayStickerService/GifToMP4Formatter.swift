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
    
    private let gif: GIF
    private var outputURL: URL?
    private(set) var videoWriter: AVAssetWriter?
    private(set) var videoWriterInput: AVAssetWriterInput?
    private(set) var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    
    var videoSize : CGSize {
        //The size of the video must be a multiple of 16
        return CGSize(width: floor(gif.size.width / 16) * 16, height: floor(gif.size.height / 16) * 16)
    }
    
    init?(data : Data) {
        guard let gif = GIF(data: data) else {
            return nil
        }
        self.gif = gif
    }
    
    private func prepare() {
        
        guard let outputURL = outputURL else {
            assertionFailure()
            return
        }
        
        try? FileManager.default.removeItem(at: outputURL)

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
        
        videoWriter = try? AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mp4)
        videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: avOutputSettings)
        
        guard let videoWriter = videoWriter, let videoWriterInput = videoWriterInput else {
            assertionFailure()
            return
        }
        
        videoWriter.add(videoWriterInput)
        
        pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
        videoWriter.startWriting()
        videoWriter.startSession(atSourceTime: kCMTimeZero)
    }
    
    func convertAndExport(to url: URL , completion: @escaping () -> Void ) {
        outputURL = url
        prepare()
        
        guard let videoWriterInput = videoWriterInput, let videoWriter = videoWriter else {
            return
        }

        var index = 0
        var delay = 0.0 - gif.frameDurations[0]
        let queue = DispatchQueue(label: "mediaInputQueue")
        
        videoWriterInput.requestMediaDataWhenReady(on: queue) {
    
            guard let framesCount = self.gif.frames?.count else {
                return
            }

            while index < framesCount {
                if videoWriterInput.isReadyForMoreMediaData == false {
                    break
                }
                
                autoreleasepool{
                    
                if let cgImage = self.gif.getFrame(at: index) {
                        let frameDuration = self.gif.frameDurations[index]
                        delay += Double(frameDuration)
                        let presentationTime = CMTime(seconds: delay, preferredTimescale: 600)
                        let result = self.addImage(image: UIImage(cgImage: cgImage), withPresentationTime: presentationTime)
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
                    completion()
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
        //let aspectRatio = min(horizontalRatio, verticalRatio) // ScaleAspectFit
        let newSize = CGSize(width: image.size.width * aspectRatio, height: image.size.height * aspectRatio)

        let x = newSize.width < size.width ? (size.width - newSize.width) / 2 : -(newSize.width-size.width)/2
        let y = newSize.height < size.height ? (size.height - newSize.height) / 2 : -(newSize.height-size.height)/2

        context.draw(CGimage, in: CGRect(x:x, y:y, width:newSize.width, height:newSize.height))
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))

        return pixelBuffer
    }
}


import ImageIO
import MobileCoreServices

final class GIF {

    private let frameDelayThreshold = 0.02
    private(set) var duration = 0.0
    private(set) var imageSource: CGImageSource?
    private(set) var frames: [CGImage?]?
    private(set) lazy var frameDurations = [TimeInterval]()
    
    var size : CGSize {
        guard let frames = frames, let photo = frames.first, let cgImage = photo else {
            return .zero
        }
        return CGSize(width: cgImage.width, height: cgImage.height)
    }
    private lazy var getFrameQueue: DispatchQueue = DispatchQueue(label: "gif.frame.queue", qos: .userInteractive)


    init?(data: Data) {
        guard let imgSource = CGImageSourceCreateWithData(data as CFData, nil), let imgType = CGImageSourceGetType(imgSource) , UTTypeConformsTo(imgType, kUTTypeGIF) else {
            return nil
        }
        self.imageSource =  imgSource
        
        
        guard let picSource = self.imageSource  else {
            assertionFailure()
            return
        }
        
        
        let imgCount = CGImageSourceGetCount(picSource)
        frames = [CGImage?](repeating: nil, count: imgCount)
        for i in 0..<imgCount {
            autoreleasepool{
                let delay = getGIFFrameDuration(imgSource: picSource, index: i)
                frameDurations.append(delay)
                duration += delay
                
                getFrameQueue.async { [weak self] in
                    self?.frames?[i] = CGImageSourceCreateImageAtIndex(picSource, i, nil)
                }
            }
        }
    }

    func getFrame(at index: Int) -> CGImage? {
        
        guard let picSource = self.imageSource  else {
            assertionFailure()
            return nil
        }
        
        if index >= CGImageSourceGetCount(picSource) {
            return nil
        }
        if let frame = frames?[index] {
            return frame
        } else {
            let frame = CGImageSourceCreateImageAtIndex(picSource, index, nil)
            frames?[index] = frame
            return frame
        }
    }

    private func getGIFFrameDuration(imgSource: CGImageSource, index: Int) -> TimeInterval {
        guard
            let frameProperties = CGImageSourceCopyPropertiesAtIndex(imgSource, index, nil) as? NSDictionary,
            let gifProperties = frameProperties[kCGImagePropertyGIFDictionary] as? NSDictionary,
            let unclampedDelay = gifProperties[kCGImagePropertyGIFUnclampedDelayTime] as? TimeInterval
        else {
            return 0.02
        }

        var frameDuration = TimeInterval(0)

        if unclampedDelay < 0 {
            frameDuration = gifProperties[kCGImagePropertyGIFDelayTime] as? TimeInterval ?? 0.0
        } else {
            frameDuration = unclampedDelay
        }

        /* Implement as Browsers do: Supports frame delays as low as 0.02 s, with anything below that being rounded up to 0.10 s.
         http://nullsleep.tumblr.com/post/16524517190/animated-gif-minimum-frame-delay-browser-compatibility */

        if (frameDuration < frameDelayThreshold - .ulpOfOne) {
            frameDuration = 0.1;
        }

        return frameDuration
    }
}
