//
//  ImageBlurOperation.swift
//  Depo
//
//  Created by Konstantin on 10/4/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import BlurImageProcessor


final class ImageBlurOperation: Operation, DataTransferrableOperation {
    
    var inputData: AnyObject?
    private var imageProcessor: ALDBlurImageProcessor?
    private let semaphore = DispatchSemaphore(value: 0)
    private (set) var outputData: AnyObject?
    
    
    override func cancel() {
        super.cancel()
        
        semaphore.signal()
        imageProcessor?.cancelAsyncBlurOperations()
    }

    override func main() {
        guard !isCancelled, let inputImage = inputData as? UIImage else {
            return
        }
        
        blurEffect(image: inputImage) { [weak self] image in
            self?.outputData = image
            self?.semaphore.signal()
        }
        
        semaphore.wait()
    }
    
    
    private func blurEffect(image: UIImage, completion: @escaping (_ image: UIImage?)->Void) {
        /// if isSimulator
        /// #if targetEnvironment(simulator)
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            completion(image)
        #else
        
        imageProcessor = ALDBlurImageProcessor(image: image)
        imageProcessor?.asyncBlur(withRadius: 2, iterations: 1, successBlock: { image in
            completion(image)
        }, errorBlock: { _ in
            completion(nil)
        })
        
        
//        guard let gaussianFilter = CIFilter(name: "CIGaussianBlur"),
//            let cropFilter = CIFilter(name: "CICrop"),
//            let inputImage = CIImage(image: image),
//            !isCancelled
//        else {
//            return nil
//        }
//
//        gaussianFilter.setValue(1, forKey: kCIInputRadiusKey)
//        gaussianFilter.setValue(inputImage, forKey: kCIInputImageKey)
//
//        guard !isCancelled, let gaussianImage = gaussianFilter.outputImage else {
//            return nil
//        }
//
//        cropFilter.setValue(gaussianImage, forKey: kCIInputImageKey)
//        cropFilter.setValue(CIVector(cgRect: inputImage.extent), forKey: "inputRectangle")
//
//
//        guard !isCancelled, let croppedImage = cropFilter.outputImage else {
//            return nil
//        }
//
//        return UIImage(ciImage: croppedImage)
        #endif

        ///TODO: check what is wrong, I had crashes on context.createCGImage
        ///the algorithm above works without crashes so far
        
        
//        ///https://stackoverflow.com/questions/27632618/cicontext-bad-access-crash
//        /// EAGLContext.setCurrent(nil) was used to prevent createCGImage bad_access crash (no guarantee)
//        EAGLContext.setCurrent(nil)
//
//        let context = CIContext(options: nil)
//        currentFilter.setValue(inputImage, forKey: kCIInputImageKey)
//        currentFilter.setValue(1, forKey: kCIInputRadiusKey)
//
//        if isCancelled {
//            return nil
//        }
//
//        cropFilter.setValue(currentFilter.outputImage, forKey: kCIInputImageKey)
//        cropFilter.setValue(CIVector(cgRect: inputImage.extent), forKey: "inputRectangle")
//
//        guard !isCancelled, let output = cropFilter.outputImage else {
//            return nil
//        }
//
//        guard let cgImg = context.createCGImage(output, from: output.extent) else {
//            return nil
//        }
//
//        if isCancelled {
//            return nil
//        }
//
//        return UIImage(cgImage: cgImg)
    }
}
